use crate::io::{Input, Solution};
use crate::year2019::computer::Computer;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

type Program = Input;

impl Program {
    fn program(&self) -> Vec<i32> {
        self.int_vec(",")
    }
}

fn part_one(input: &Input) -> i32 {
    let mut computer = Computer::new(input.program());
    computer.run();
    computer.output().unwrap()
}

fn part_two(input: &Input) -> i32 {
    let mut computer = Computer::automated(input.program(), vec![5]);
    computer.run();
    computer.output().unwrap()
}
