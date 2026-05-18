use crate::io::{Input, Solution};
use crate::year2019::computer::Program;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let mut program = Program::from((input, 1));
    program.run();
    program.output().unwrap()
}

fn part_two(input: &Input) -> i64 {
    let mut program = Program::from((input, 5));
    program.run();
    program.output().unwrap()
}
