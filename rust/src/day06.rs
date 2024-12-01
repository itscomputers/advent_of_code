use std::str::FromStr;
use itertools::Itertools;
use lazy_static::lazy_static;
use std::fs::read_to_string;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/06.txt").unwrap();
}

pub fn main() {
    println!("day 06");
    println!("part 1: {}", part1(&INPUT));
    println!("part 2: {}", part2(&INPUT));
}

fn part1(input: &str) -> isize {
    match data(input, extract_numbers).as_slice() {
        [times, distances] => times
            .iter()
            .zip(distances)
            .map(|(time, distance)| winning_count(*time, *distance))
            .product::<isize>(),
        _ => 0
    }
}

fn part2(input: &str) -> isize {
    match data(input, extract_number).as_slice() {
        [time, distance] => winning_count(*time, *distance),
        _ => 0,
    }
}

fn data<T>(input: &str, function: fn(&str) -> T) -> Vec<T> {
    input
        .lines()
        .map(|line| function(line))
        .collect::<Vec<T>>()
}

fn extract_numbers(input: &str) -> Vec<isize> {
    input
        .split_ascii_whitespace()
        .dropping(1)
        .map(|s| isize::from_str(s).unwrap())
        .collect::<Vec<isize>>()
}

fn extract_number(input: &str) -> isize {
    isize::from_str(
        input.split_ascii_whitespace().dropping(1).join("").as_str()
    ).unwrap()
}

fn winning_count(time: isize, distance: isize) -> isize {
    let sol = quadratic_solution(1, -time, distance);
    let mut isol = sol as isize;
    if sol.floor() == sol {
        isol -= 1;
    }
    2 * isol - time + 1
}

fn quadratic_solution(a: isize, b: isize, c: isize) -> f32 {
    ((-b as f32) + ((b.pow(2) - 4 * a * c) as f32).sqrt()) / 2_f32
}

#[cfg(test)]
mod tests {
    use super::*;

    lazy_static! {
        static ref TEST_INPUT: String = String::from(
            "\
            Time:      7  15   30\n\
            Distance:  9  40  200"
        );
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part1(&TEST_INPUT), 288);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part2(&TEST_INPUT), 71503);
    }
}