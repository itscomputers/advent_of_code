use itertools::Itertools;
use std::str::FromStr;

use crate::solution::Solution;
use crate::year2019::computer::Computer;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> usize {
    let program = program(&input, 12, 2);
    Computer::new(program).run().program()[0]
}

fn part_two(input: &String) -> usize {
    match (0..100).permutations(2).find(|vec| {
        let program = program(&input, vec[0], vec[1]);
        Computer::new(program).run().program()[0] == 19690720
    }) {
        Some(vec) => 100 * vec[0] + vec[1],
        _ => 0,
    }
}

fn program(input: &String, v1: usize, v2: usize) -> Vec<usize> {
    let mut program = input
        .trim()
        .split(",")
        .map(|x| usize::from_str(x).unwrap())
        .collect::<Vec<usize>>();
    program[1] = v1;
    program[2] = v2;
    program
}
