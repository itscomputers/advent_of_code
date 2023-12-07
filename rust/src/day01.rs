use lazy_static::lazy_static;
use regex::{Captures, Regex};
use std::collections::HashMap;
use std::fs::read_to_string;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/01.txt").unwrap();
    static ref PATTERN: String = String::from(r"\d|one|two|three|four|five|six|seven|eight|nine");
    static ref HASHMAP: HashMap<String, usize> = {
        let mut h = HashMap::new();
        vec![
            "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
        ]
        .iter()
        .enumerate()
        .for_each(|(i, &s)| {
            h.insert(s.to_string(), i + 1);
        });
        h
    };
}

pub fn main() {
    println!("day 01");
    println!(
        "part 1: {}",
        total(&INPUT.as_ref(), r"\d", &HashMap::from([]))
    );
    println!(
        "part 2: {}",
        total(&INPUT.as_ref(), &PATTERN.as_ref(), &HASHMAP)
    );
}

fn build_number(str: &String, hashmap: &HashMap<String, usize>) -> usize {
    match hashmap.get(str) {
        Some(n) => *n,
        None => str.parse().unwrap(),
    }
}

fn total(input: &str, pattern: &str, hashmap: &HashMap<String, usize>) -> usize {
    input
        .lines()
        .map(|line| get_number(line, pattern, hashmap))
        .sum()
}

fn get_number(line: &str, pattern: &str, hashmap: &HashMap<String, usize>) -> usize {
    let captures: Vec<Captures<'_>> =
        vec![format!("({}).*$", pattern), format!("^.*({})", pattern)]
            .iter()
            .map(|s| Regex::new(&s).unwrap().captures(line).unwrap())
            .collect();
    let a = build_number(&captures[0][1].to_string(), hashmap);
    let b = build_number(&captures[1][1].to_string(), hashmap);
    10 * a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn part_one() {
        let input = "\
            1abc2\n\
            pqr3stu8vwx\n\
            a1b2c3d4e5f\n\
            treb7uchet";
        assert_eq!(total(input, r"\d", &HashMap::from([])), 142);
    }

    #[test]
    fn part_two() {
        let input = "\
            two1nine\n\
            eightwothree\n\
            abcone2threexyz\n\
            xtwone3four\n\
            4nineeightseven2\n\
            zoneight234\n\
            7pqrstsixteen";
        assert_eq!(total(input, &PATTERN, &HASHMAP), 281);
    }
}
