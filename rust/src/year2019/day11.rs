use std::collections::HashMap;

use crate::{
    io::{Input, Solution},
    point::{Direction, Point},
    year2019::computer::{Computer, Program},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    let mut bot = PaintBot::from(input);
    bot.paint();
    bot.tagged()
}

fn part_two(input: &Input) -> usize {
    let mut bot = PaintBot::from(input);
    bot.tagged.insert(bot.position, 1);
    bot.paint();
    bot.display();
    1
}

struct PaintBot {
    computer: Computer,
    position: Point,
    direction: Direction,
    dimensions: (Point, Point),
    tagged: HashMap<Point, i64>,
}

impl PaintBot {
    fn paint(&mut self) {
        while !self.computer.terminated() {
            self.step();
        }
    }

    fn tagged(&self) -> usize {
        self.tagged.len()
    }

    fn step(&mut self) {
        let color = self.computer.io_loop(self.count() % 2);
        let rotation = self.computer.next_output();
        self.apply(color);
        self.advance(rotation);
    }

    fn apply(&mut self, color: i64) {
        let count = self.count();
        if color != count % 2 {
            self.tagged.insert(self.position, count + 1);
        }
    }

    fn advance(&mut self, rotation: i64) {
        if rotation == 1 {
            self.direction = self.direction.cw();
        } else {
            self.direction = self.direction.ccw();
        }
        self.position = self.position + Point::from(self.direction);
        self.update_dimensions();
    }

    fn count(&self) -> &i64 {
        self.tagged.get(&self.position).unwrap_or(&0)
    }

    fn update_dimensions(&mut self) {
        let (mut nw, mut se) = self.dimensions;
        if self.position.x < nw.x {
            nw.x = self.position.x;
        }
        if self.position.y < nw.y {
            nw.y = self.position.y;
        }
        if self.position.x > se.x {
            se.x = self.position.x;
        }
        if self.position.y > se.y {
            se.y = self.position.y;
        }
        self.dimensions = (nw, se);
    }

    fn display(&self) {
        let (nw, se) = self.dimensions;
        for y in nw.y..=se.y {
            let line = (nw.x..=se.x)
                .map(|x| match self.tagged.get(&Point::new(x, y)) {
                    Some(v) if v % 2 == 1 => '#',
                    _ => ' ',
                })
                .collect::<String>();
            println!("{}", line);
        }
    }
}

impl From<&Input> for PaintBot {
    fn from(input: &Input) -> Self {
        let computer = Computer::new(Program::from(input));
        let position = Point::new(0, 0);
        let direction = Direction::Up;
        let tagged = HashMap::new();
        let dimensions = (Point::new(0, 0), Point::new(0, 0));
        Self {
            computer,
            position,
            direction,
            dimensions,
            tagged,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from("4,0,99")
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 1);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 1);
    }
}
