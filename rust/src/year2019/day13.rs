use std::collections::HashSet;

use crate::{
    io::{Input, Solution},
    point::Point,
    year2019::computer::{Computer, Program, IO},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    block_count(input)
}

fn part_two(input: &Input) -> i64 {
    Arcade::from(input).play()
}

fn block_count(input: &Input) -> i64 {
    let mut computer = Computer::new(Program::from(input));
    let mut count = 0;
    while !computer.terminated() {
        computer.next_output();
        computer.next_output();
        if computer.next_output() == 2 {
            count += 1;
        }
    }
    count
}

struct Arcade {
    computer: Computer,
    paddle: Point,
    ball: Point,
    blocks: HashSet<Point>,
    score: i64,
}

impl Arcade {
    fn play(&mut self) -> i64 {
        while !self.computer.terminated() {
            self.step();
        }
        self.score
    }

    fn step(&mut self) {
        match self.computer.next_io() {
            IO::Terminated => {}
            IO::Input => self.handle_input(),
            IO::Output => self.handle_output(),
        }
    }

    fn handle_input(&mut self) {
        let input = match self.paddle.x.cmp(&self.ball.x) {
            std::cmp::Ordering::Less => 1,
            std::cmp::Ordering::Greater => -1,
            std::cmp::Ordering::Equal => 0,
        };
        self.computer.input(input);
    }

    fn handle_output(&mut self) {
        self.computer.interact();
        let x = *self.computer.output() as i32;
        let y = self.computer.next_output() as i32;
        let pt = Point::new(x, y);
        match (x, y, self.computer.next_output()) {
            (-1, 0, score) => {
                self.score = score;
            }
            (_, _, 2) => {
                self.blocks.insert(pt);
            }
            (_, _, 3) => {
                self.paddle = pt;
            }
            (_, _, 4) => {
                self.ball = pt;
            }
            _ => {}
        }
    }
}

impl From<&Input> for Arcade {
    fn from(input: &Input) -> Self {
        let mut program = Program::from(input);
        program.set(0, 2);
        let computer = Computer::new(program);
        let paddle = Point::new(0, 0);
        let ball = Point::new(0, 0);
        let blocks = HashSet::new();
        let score = 0;
        Self {
            computer,
            paddle,
            ball,
            blocks,
            score,
        }
    }
}
