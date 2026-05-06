use crate::io::{Input, Solution};
use crate::year2019::computer::Computer;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn program(input: &Input) -> Vec<i32> {
    input.int_vec(",")
}

fn part_one(input: &Input) -> i32 {
    let mut computer = Computer::new(program(input));
    computer.run();
    computer.output().unwrap()
}

fn part_two(input: &Input) -> i32 {
    let mut computer = Computer::automated(program(input), vec![5]);
    computer.run();
    computer.output().unwrap()
}
