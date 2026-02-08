use std::str::FromStr;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn predict_sum(&self, func: fn(Vec<i32>) -> i32) -> i32 {
        self.data
            .lines()
            .map(|line| {
                func(
                    line.split_ascii_whitespace()
                        .map(|s| i32::from_str(s).unwrap())
                        .collect::<Vec<i32>>(),
                )
            })
            .sum::<i32>()
    }
}

fn part_one(input: &Input) -> i32 {
    input.predict_sum(predict_right)
}

fn part_two(input: &Input) -> i32 {
    input.predict_sum(predict_left)
}

fn predict_right(history: Vec<i32>) -> i32 {
    differentiate(history)
        .iter()
        .fold(0, |acc, list| acc + list.last().unwrap())
}

fn predict_left(history: Vec<i32>) -> i32 {
    let mut sequences = differentiate(history);
    sequences.reverse();
    sequences
        .iter()
        .fold(0, |acc, list| list.first().unwrap() - acc)
}

fn differentiate(sequence: Vec<i32>) -> Vec<Vec<i32>> {
    let mut sequences = vec![sequence];

    loop {
        let last: &Vec<i32> = sequences.last().unwrap();
        if last.iter().all(|n| n == last.first().unwrap()) {
            return sequences;
        } else {
            sequences.push(differences(last));
        }
    }
}

fn differences(sequence: &[i32]) -> Vec<i32> {
    sequence
        .windows(2)
        .map(|slice| match slice {
            &[n1, n2] => n2 - n1,
            _ => 0,
        })
        .collect::<Vec<i32>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            "\
            0 3 6 9 12 15\n\
            1 3 6 10 15 21\n\
            10 13 16 21 30 45",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 114);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 2);
    }
}
