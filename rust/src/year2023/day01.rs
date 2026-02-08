use regex::{Captures, Regex};
use std::collections::HashMap;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> u32 {
    total(&input.data, r"\d", &HashMap::from([]))
}

fn part_two(input: &Input) -> u32 {
    let pattern = r"\d|one|two|three|four|five|six|seven|eight|nine";
    let map = HashMap::from_iter(
        [
            "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        ]
        .iter()
        .enumerate()
        .map(|(i, &s)| (s.to_string(), (i + 1) as u32)),
    );

    total(&input.data, pattern, &map)
}

fn build_number(str: &String, map: &HashMap<String, u32>) -> u32 {
    match map.get(str) {
        Some(n) => *n,
        None => str.parse().unwrap(),
    }
}

fn total(input: &str, pattern: &str, map: &HashMap<String, u32>) -> u32 {
    input
        .lines()
        .map(|line| get_number(line, pattern, map))
        .sum()
}

fn get_number(line: &str, pattern: &str, map: &HashMap<String, u32>) -> u32 {
    let captures: Vec<Captures<'_>> = [format!("({}).*$", pattern), format!("^.*({})", pattern)]
        .iter()
        .map(|s| Regex::new(s).unwrap().captures(line).unwrap())
        .collect();
    let a = build_number(&captures[0][1].to_string(), map);
    let b = build_number(&captures[1][1].to_string(), map);
    10 * a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = Input::from_str(
            "\
            1abc2\n\
            pqr3stu8vwx\n\
            a1b2c3d4e5f\n\
            treb7uchet",
        );
        assert_eq!(part_one(&input), 142);
    }

    #[test]
    fn test_part_two() {
        let input = Input::from_str(
            "\
            two1nine\n\
            eightwothree\n\
            abcone2threexyz\n\
            xtwone3four\n\
            4nineeightseven2\n\
            zoneight234\n\
            7pqrstsixteen",
        );
        assert_eq!(part_two(&input), 281);
    }
}
