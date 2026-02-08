use regex::Regex;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> u32 {
    input
        .data
        .lines()
        .enumerate()
        .filter(|(_, line)| {
            get_maxes(line)
                .iter()
                .zip([14, 12, 13].as_ref())
                .all(|(max, bound)| max <= bound)
        })
        .map(|(i, _)| (i + 1) as u32)
        .sum()
}

fn part_two(input: &Input) -> u32 {
    input
        .data
        .lines()
        .map(|line| get_maxes(line).iter().product::<u32>())
        .sum()
}

fn get_maxes(line: &str) -> [u32; 3] {
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

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            "\
            Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green\n\
            Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue\n\
            Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red\n\
            Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red\n\
            Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 8);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 2286)
    }
}
