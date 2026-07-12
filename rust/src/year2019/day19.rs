use crate::{
    grid::Grid,
    io::{Input, Solution},
    year2019::computer::{Computer, Program},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let drone = Drone::from(input);
    (0..50)
        .map(|x| (0..50).map(|y| drone.test((x, y))).sum::<i64>())
        .sum()
}

fn part_two(input: &Input) -> i64 {
    let drone = Drone::from(input);
    let (x, y) = drone.first_square(100);
    10000 * x + y
}

fn lower_left(upper_right: &(i64, i64), len: i64) -> (i64, i64) {
    (upper_right.0 - len + 1, upper_right.1 + len - 1)
}

struct Drone {
    program: Program,
}

impl Drone {
    fn computer(&self) -> Computer {
        Computer::new(self.program.clone())
    }

    fn test(&self, point: (i64, i64)) -> i64 {
        let mut computer = self.computer();
        computer.input(point.0);
        computer.input(point.1);
        computer.next_output()
    }

    fn contains_square(&self, upper_right: (i64, i64), len: i64) -> bool {
        self.test(upper_right) == 1 && self.test(lower_left(&upper_right, len)) == 1
    }

    fn max_square(&self, row: i64) -> (i64, (i64, i64)) {
        let mut x = row;
        let mut y = row;
        while self.test((x, y)) == 0 {
            x -= 1;
        }
        while self.test((x, y)) == 1 {
            x -= 1;
            y += 1;
        }
        (y - row, (x + 1, row))
    }

    fn first_square(&self, size: i64) -> (i64, i64) {
        let mut square = self.find_square(size);
        loop {
            let candidate = self.max_square(square.1 - 1);
            if candidate.0 == size {
                square = candidate.1;
            } else {
                break;
            }
        }
        square
    }

    fn find_square(&self, size: i64) -> (i64, i64) {
        let mut upper = size * 15;
        while self.max_square(upper).0 < size {
            upper *= 2;
        }
        let mut lower = upper / 2;
        while lower <= upper {
            let mid = (lower + upper) / 2;
            match self.max_square(mid) {
                (s, _) if s < size => {
                    lower = mid + 1;
                }
                (s, _) if s > size => {
                    upper = mid - 1;
                }
                (_, point) => {
                    return point;
                }
            }
        }
        (0, 0)
    }

    fn grid(&self, upper: (i64, i64)) -> Grid<char> {
        let mut grid = Grid::default();
        for x in 0..=upper.0 {
            for y in 0..=upper.1 {
                let ch = {
                    if self.test((x, y)) == 1 {
                        '#'
                    } else {
                        '.'
                    }
                };
                grid.insert((x as i32, y as i32), ch)
            }
        }
        grid
    }
}

impl From<&Input> for Drone {
    fn from(input: &Input) -> Self {
        let program = Program::from(input);
        Self { program }
    }
}
