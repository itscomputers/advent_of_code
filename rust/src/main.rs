#![allow(dead_code)]

use std::env;

mod day01;
mod day02;
mod day03;
mod day04;
mod day09;
mod day06;

fn main() {
    let args: Vec<String> = env::args().collect();
    match args[1].as_str() {
        "01" => day01::main(),
        "02" => day02::main(),
        "03" => day03::main(),
        "04" => day04::main(),
        "06" => day06::main(),
        "09" => day09::main(),
        _ => {}
    }
}
