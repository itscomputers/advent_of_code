use itertools::Itertools;

use crate::io::{Input, Solution};
use crate::year2019::computer::Program;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let mut program = Program::new(program_data(input, 12, 2));
    program.run();
    program.get(0)
}

fn part_two(input: &Input) -> i64 {
    match (0..100).permutations(2).find(|vec| {
        let mut program = Program::new(program_data(input, vec[0], vec[1]));
        program.run();
        program.get(0) == 19690720
    }) {
        Some(vec) => 100 * vec[0] + vec[1],
        _ => 0,
    }
}

fn program_data(input: &Input, v1: i64, v2: i64) -> Vec<i64> {
    let mut program = input.int_vec(",");
    program[1] = v1;
    program[2] = v2;
    program
}
