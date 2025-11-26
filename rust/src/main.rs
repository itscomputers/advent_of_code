#![allow(dead_code)]

use std::env;
use std::fs::read_to_string;

mod line;
mod parser;
mod point;
mod solution;

mod year2019;
mod year2023;
mod year2024;
mod year2025;

fn main() {
    let args: Vec<String> = env::args().collect();
    let year = args[1].as_str();
    let day = args[2].as_str();
    let part = if args.len() == 4 {
        args[3].as_str()
    } else {
        ""
    };
    let solution = get_solution(&year, &day, &part);
    println!("{}", solution);
}

fn get_solution(year: &str, day: &str, part: &str) -> solution::Solution {
    let input = get_input(&year, &day);
    match year {
        "2019" => year2019::solve(&day, &part, &input),
        "2023" => year2023::solve(&day, &part, &input),
        "2024" => year2024::solve(&day, &part, &input),
        "2025" => year2025::solve(&day, &part, &input),
        _ => solution::Solution::default(),
    }
}

fn get_input(year: &str, day: &str) -> String {
    let filepath = format!("../inputs/{}/{}.txt", &year, &day);
    let input = read_to_string(&filepath);
    match input {
        Ok(s) => s,
        Err(_) => panic!("{}", format!("could not find input file {}", filepath)),
    }
}
