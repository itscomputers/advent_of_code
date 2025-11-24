use crate::solution::Solution;

mod day01;

pub fn solve(day: &str, part: &str, input: &String) -> Solution {
    match day {
        "01" => day01::solve(&part, &input),
        _ => Solution::default(),
    }
}
