use regex::{Captures, Regex};
use std::collections::HashMap;

use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> usize {
    total(&input.as_ref(), r"\d", &HashMap::from([]))
}

fn part_two(input: &String) -> usize {
    let pattern = r"\d|one|two|three|four|five|six|seven|eight|nine";
    let map = HashMap::from_iter(
        vec![
            "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        ]
        .iter()
        .enumerate()
        .map(|(i, &s)| (s.to_string(), i + 1)),
    );

    total(&input.as_ref(), &pattern, &map)
}

fn build_number(str: &String, map: &HashMap<String, usize>) -> usize {
    match map.get(str) {
        Some(n) => *n,
        None => str.parse().unwrap(),
    }
}

fn total(input: &str, pattern: &str, map: &HashMap<String, usize>) -> usize {
    input
        .lines()
        .map(|line| get_number(line, pattern, map))
        .sum()
}

fn get_number(line: &str, pattern: &str, map: &HashMap<String, usize>) -> usize {
    let captures: Vec<Captures<'_>> =
        vec![format!("({}).*$", pattern), format!("^.*({})", pattern)]
            .iter()
            .map(|s| Regex::new(&s).unwrap().captures(line).unwrap())
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
        let input = String::from(
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
        let input = String::from(
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
