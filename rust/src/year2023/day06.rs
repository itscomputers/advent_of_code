use itertools::Itertools;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn numbers(&self) -> Vec<i64> {
        self.data
            .split_ascii_whitespace()
            .dropping(1)
            .map(|s| s.parse::<i64>().unwrap())
            .collect::<Vec<i64>>()
    }

    fn number(&self) -> i64 {
        self.data
            .split_ascii_whitespace()
            .dropping(1)
            .join("")
            .parse::<i64>()
            .unwrap()
    }
}

fn part_one(input: &Input) -> i64 {
    match input
        .data
        .lines()
        .map(extract_numbers)
        .collect::<Vec<Vec<i64>>>()
        .as_slice()
    {
        [times, distances] => times
            .iter()
            .zip(distances)
            .map(|(time, distance)| winning_count(*time, *distance))
            .product::<i64>(),
        _ => 0,
    }
}

fn part_two(input: &Input) -> i64 {
    match input
        .data
        .lines()
        .map(extract_number)
        .collect::<Vec<i64>>()
        .as_slice()
    {
        [time, distance] => winning_count(*time, *distance),
        _ => 0,
    }
}

fn extract_numbers(line: &str) -> Vec<i64> {
    line.split_ascii_whitespace()
        .dropping(1)
        .map(|s| s.parse::<i64>().unwrap())
        .collect::<Vec<i64>>()
}

fn extract_number(line: &str) -> i64 {
    line.split_ascii_whitespace()
        .dropping(1)
        .join("")
        .parse::<i64>()
        .unwrap()
}

fn winning_count(time: i64, distance: i64) -> i64 {
    let sol = quadratic_solution(1, -time, distance);
    let mut isol = sol as i64;
    if sol.floor() == sol {
        isol -= 1;
    }
    2 * isol - time + 1
}

fn quadratic_solution(a: i64, b: i64, c: i64) -> f32 {
    ((-b as f32) + ((b.pow(2) - 4 * a * c) as f32).sqrt()) / 2_f32
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            "\
            Time:      7  15   30\n\
            Distance:  9  40  200",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 288);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 71503);
    }
}
