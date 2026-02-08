use itertools::Itertools;

use crate::io::{Input, Solution};
use crate::year2019::computer::Computer;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i32 {
    let program = program(input, 12, 2);
    let mut computer = Computer::new(program);
    computer.run();
    computer.program()[0]
}

fn part_two(input: &Input) -> i32 {
    match (0..100).permutations(2).find(|vec| {
        let program = program(input, vec[0], vec[1]);
        let mut computer = Computer::new(program);
        computer.run();
        computer.program()[0] == 19690720
    }) {
        Some(vec) => 100 * vec[0] + vec[1],
        _ => 0,
    }
}

fn program(input: &Input, v1: i32, v2: i32) -> Vec<i32> {
    let mut program = input.int_vec("\n");
    program[1] = v1;
    program[2] = v2;
    program
}
