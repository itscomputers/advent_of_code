use crate::{
    grid::Grid,
    io::{Input, Solution},
    point::{Direction, Point},
    year2019::computer::{Computer, Program},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    Scaffold::from(input).alignment()
}

fn part_two(input: &Input) -> i64 {
    let scaffold = Scaffold::from(input);
    let mut ascii = Ascii::new(scaffold);
    let routine = Routine::new(ascii.instructions());
    let mut program = Program::with_inputs(input.int_vec(","), routine.inputs());
    program.set(0, 2);
    program.run();
    program.output().unwrap()
}

struct Scaffold {
    grid: Grid<char>,
}

impl Scaffold {
    fn contains(&self, point: &Point) -> bool {
        self.grid.value(&(point.x, point.y)) == '#'
    }

    fn is_intersection(&self, point: &Point) -> bool {
        self.contains(point) && point.neighbors().iter().all(|pt| self.contains(pt))
    }

    fn alignment(&self) -> i64 {
        self.grid
            .points()
            .map(Point::from)
            .filter(|pt| self.is_intersection(pt))
            .map(|pt| (pt.x * pt.y) as i64)
            .sum::<i64>()
    }

    fn robot(&self) -> (Point, Direction) {
        self.grid
            .find(|_, ch| ['>', 'v', '<', '^'].contains(ch))
            .map(|((x, y), ch)| {
                let point = Point::new(*x, *y);
                match ch {
                    '>' => (point, Direction::Right),
                    'v' => (point, Direction::Down),
                    '<' => (point, Direction::Left),
                    '^' => (point, Direction::Up),
                    _ => unreachable!(),
                }
            })
            .unwrap()
    }
}

impl From<&Input> for Scaffold {
    fn from(input: &Input) -> Self {
        let mut computer = Computer::new(Program::from(input));
        let mut display = Vec::new();
        while !computer.terminated() {
            let output = computer.next_output();
            match char::from_u32(output as u32) {
                Some(ch) => display.push(ch),
                None => display.push('?'),
            }
        }
        let grid = Grid::from(&display.iter().collect::<String>());
        Self { grid }
    }
}

struct Ascii {
    scaffold: Scaffold,
    position: Point,
    direction: Direction,
    terminated: bool,
    instructions: Vec<Instruction>,
}

impl Ascii {
    fn new(scaffold: Scaffold) -> Self {
        let (position, direction) = scaffold.robot();
        Self {
            scaffold,
            position,
            direction,
            terminated: false,
            instructions: Vec::new(),
        }
    }

    fn detect_turn(&self) -> Option<Turn> {
        if self.scaffold.contains(&self.cw_position()) {
            Some(Turn::Right)
        } else if self.scaffold.contains(&self.ccw_position()) {
            Some(Turn::Left)
        } else {
            None
        }
    }

    fn add_instruction(&mut self) {
        match self.detect_turn() {
            Some(turn) => {
                match turn {
                    Turn::Right => self.direction = self.direction.cw(),
                    Turn::Left => self.direction = self.direction.ccw(),
                }
                let mut distance = 0;
                while self.scaffold.contains(&self.next_position()) {
                    self.position = self.next_position();
                    distance += 1;
                }
                self.instructions.push(Instruction { turn, distance });
            }
            None => {
                self.terminated = true;
            }
        }
    }

    fn next_position(&self) -> Point {
        self.potential_position(&self.direction)
    }

    fn cw_position(&self) -> Point {
        self.potential_position(&self.direction.cw())
    }

    fn ccw_position(&self) -> Point {
        self.potential_position(&self.direction.ccw())
    }

    fn potential_position(&self, direction: &Direction) -> Point {
        self.position + Point::from(direction)
    }

    fn instructions(&mut self) -> &Vec<Instruction> {
        while !self.terminated {
            self.add_instruction();
        }
        &self.instructions
    }

    fn validate(&self, routine: &Routine) {
        let mut index = 0;
        for i in routine.main {
            for instruction in &routine.sub_routines[i].instructions {
                assert_eq!(instruction, &self.instructions[index]);
                index += 1;
            }
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
struct Instruction {
    turn: Turn,
    distance: i64,
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Turn {
    Left,
    Right,
}

impl Turn {
    fn code(&self) -> i64 {
        match self {
            Turn::Left => 'L' as i64,
            Turn::Right => 'R' as i64,
        }
    }
}

struct Routine {
    main: [usize; 10],
    sub_routines: [SubRoutine; 3],
}

impl Routine {
    fn new(instructions: &[Instruction]) -> Self {
        let a = SubRoutine {
            label: 'A',
            instructions: instructions[0..3].to_vec(),
        };
        let b = SubRoutine {
            label: 'B',
            instructions: instructions[3..7].to_vec(),
        };
        let c = SubRoutine {
            label: 'C',
            instructions: instructions[14..18].to_vec(),
        };
        Self {
            main: [0, 1, 0, 1, 2, 0, 1, 2, 0, 2],
            sub_routines: [a, b, c],
        }
    }

    fn main(&self) -> Vec<i64> {
        let mut codes = Vec::new();
        for (i, index) in self.main.iter().enumerate() {
            codes.push(self.sub_routines[*index].code());
            if i < self.main.len() - 1 {
                codes.push(',' as i64);
            } else {
                codes.push('\n' as i64);
            }
        }
        codes
    }

    fn sub_routines(&self) -> Vec<Vec<i64>> {
        self.sub_routines
            .iter()
            .map(SubRoutine::codes)
            .collect::<Vec<_>>()
    }

    fn inputs(&self) -> Vec<i64> {
        let mut inputs = Vec::new();
        for input in self.main() {
            inputs.push(input);
        }
        for sub_routine in self.sub_routines() {
            for input in sub_routine {
                inputs.push(input);
            }
        }
        inputs.push('n' as i64);
        inputs.push('\n' as i64);
        inputs
    }
}

struct SubRoutine {
    label: char,
    instructions: Vec<Instruction>,
}

impl SubRoutine {
    fn code(&self) -> i64 {
        self.label as i64
    }

    fn codes(&self) -> Vec<i64> {
        let mut codes = Vec::new();
        for (index, instruction) in self.instructions.iter().enumerate() {
            codes.push(instruction.turn.code());
            codes.push(',' as i64);
            if instruction.distance <= 9 {
                codes.push(48 + instruction.distance);
            } else {
                let half = instruction.distance / 2;
                codes.push(48 + half);
                codes.push(',' as i64);
                codes.push(48 + instruction.distance - half);
            }
            if index < self.instructions.len() - 1 {
                codes.push(',' as i64);
            } else {
                codes.push('\n' as i64);
            }
        }
        codes
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn grid() -> Grid<char> {
        Grid::from(&String::from(
            "..#..........\n\
            ..#..........\n\
            #######...###\n\
            #.#...#...#.#\n\
            #############\n\
            ..#...#...#..\n\
            ..#####...^..",
        ))
    }

    #[test]
    fn test_part_one() {
        assert_eq!(Scaffold { grid: grid() }.alignment(), 76);
    }
}
