use crate::solution::Solution;
use crate::year2019::computer::Computer;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn program(input: &String) -> Vec<isize> {
    input
        .trim()
        .split(",")
        .map(|x| x.parse::<isize>().unwrap())
        .collect::<Vec<isize>>()
}

fn part_one(input: &String) -> isize {
    let mut computer = Computer::new(program(&input));
    computer.run();
    computer.output().unwrap()
}

fn part_two(input: &String) -> isize {
    let mut computer = Computer::automated(program(&input), vec![5]);
    computer.run();
    computer.output().unwrap()
}
