use lazy_static::lazy_static;
use regex::Regex;
use std::fs::read_to_string;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/02.txt").unwrap();
}

pub fn main() {
    println!("day 02");
    println!("part 1: {}", possible_id_sum(&INPUT.as_ref()));
    println!("part 2: {}", power_sum(&INPUT.as_ref()));
}

fn get_maxes(line: &str) -> [usize; 3] {
    ["blue", "red", "green"].map(|color| {
        let str: String = format!(r"(\d+) {}", color);
        Regex::new(&str)
            .unwrap()
            .captures_iter(line)
            .map(|c| c.extract())
            .map(|(_, [n_str])| n_str.parse().unwrap())
            .max()
            .unwrap()
    })
}

fn possible_id_sum(input: &str) -> usize {
    input
        .lines()
        .enumerate()
        .filter(|(_, line)| {
            get_maxes(&line)
                .iter()
                .zip([14, 12, 13].as_ref())
                .all(|(max, bound)| max <= bound)
        })
        .map(|(i, _)| i + 1)
        .sum()
}

fn power_sum(input: &str) -> usize {
    input
        .lines()
        .map(|line| get_maxes(line).iter().product::<usize>())
        .sum()
}

#[cfg(test)]
mod tests {
    use super::*;

    lazy_static! {
        static ref INPUT: String = String::from(
            "\
            Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n\
            Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n\
            Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n\
            Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n\
            Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green"
        );
    }

    #[test]
    fn part_one() {
        assert_eq!(possible_id_sum(&INPUT.as_ref()), 8);
    }

    #[test]
    fn part_two() {
        assert_eq!(power_sum(&INPUT.as_ref()), 2286)
    }
}
