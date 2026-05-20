use crate::io::{Input, Solution};

mod computer;
mod day01;
mod day02;
mod day03;
mod day04;
mod day05;
mod day06;
mod day07;
mod day08;
mod day09;
mod day10;
mod day11;
mod day12;
mod day13;
mod day14;

pub fn solve(day: &str, part: &str, input: &Input) -> Solution {
    match day {
        "01" => day01::solve(part, input),
        "02" => day02::solve(part, input),
        "03" => day03::solve(part, input),
        "04" => day04::solve(part, input),
        "05" => day05::solve(part, input),
        "06" => day06::solve(part, input),
        "07" => day07::solve(part, input),
        "08" => day08::solve(part, input),
        "09" => day09::solve(part, input),
        "10" => day10::solve(part, input),
        "11" => day11::solve(part, input),
        "12" => day12::solve(part, input),
        "13" => day13::solve(part, input),
        "14" => day14::solve(part, input),
        _ => Solution::default(),
    }
}
