#![allow(dead_code)]

mod grid;
mod io;
mod line;
mod parser;
mod point;

mod year2019;
mod year2023;
mod year2024;
mod year2025;

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let year = get_arg(&args, 1, "year");
    let day = get_arg(&args, 2, "day");
    let part = get_arg(&args, 3, "part");
    let solution = get_solution(year.trim(), day.trim(), part.trim());
    println!("{}", solution);
}

fn get_solution(year: &str, day: &str, part: &str) -> io::Solution {
    let input = get_input(year, day);
    match year {
        "2019" => year2019::solve(day, part, &input),
        "2023" => year2023::solve(day, part, &input),
        "2024" => year2024::solve(day, part, &input),
        "2025" => year2025::solve(day, part, &input),
        _ => io::Solution::default(),
    }
}

fn get_input(year: &str, day: &str) -> io::Input {
    io::Input::build(year, day)
}

fn get_arg(args: &[String], index: usize, prompt: &str) -> String {
    if args.len() > index {
        args[index].clone()
    } else if index == 3 && args.len() == 3 {
        String::new()
    } else {
        let mut arg = String::new();
        println!("{prompt}: ");
        std::io::stdin()
            .read_line(&mut arg)
            .expect("failed to read line");
        arg
    }
}
