use crate::solution::Solution;

mod day01;
mod day02;
mod day03;

pub fn solve(day: &str, part: &str, input: &String) -> Solution {
    match day {
        "01" => day01::solve(&part, &input),
        "02" => day02::solve(&part, &input),
        "03" => day03::solve(&part, &input),
        _ => Solution::default(),
    }
}
