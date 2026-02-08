use crate::io::{Input, Solution};

mod computer;
mod day01;
mod day02;
mod day03;
mod day04;
mod day05;

pub fn solve(day: &str, part: &str, input: &Input) -> Solution {
    match day {
        "01" => day01::solve(part, &input),
        "02" => day02::solve(part, &input),
        "03" => day03::solve(part, &input),
        "04" => day04::solve(part, &input),
        "05" => day05::solve(part, &input),
        _ => Solution::default(),
    }
}
