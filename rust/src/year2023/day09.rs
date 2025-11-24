use std::str::FromStr;

use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> isize {
    predict_sum(&input, predict_right)
}

fn part_two(input: &String) -> isize {
    predict_sum(&input, predict_left)
}

fn get_histories(input: &str) -> Vec<Vec<isize>> {
    input
        .split("\n")
        .map(|line| {
            line.split_ascii_whitespace()
                .map(|s| isize::from_str(s).unwrap())
                .collect::<Vec<isize>>()
        })
        .collect()
}

fn predict_sum(input: &str, function: fn(Vec<isize>) -> isize) -> isize {
    get_histories(input)
        .iter()
        .map(|history| function(history.clone()))
        .sum::<isize>()
}

fn predict_right(history: Vec<isize>) -> isize {
    let sequences = differentiate(history);
    sequences
        .iter()
        .fold(0, |acc, list| acc + list.last().unwrap())
}

fn predict_left(history: Vec<isize>) -> isize {
    let mut sequences = differentiate(history);
    sequences.reverse();
    sequences
        .iter()
        .fold(0, |acc, list| list.first().unwrap() - acc)
}

fn differentiate(sequence: Vec<isize>) -> Vec<Vec<isize>> {
    let mut sequences = vec![sequence];

    loop {
        let last: &Vec<isize> = sequences.last().unwrap();
        if last.iter().all(|n| n == last.first().unwrap()) {
            return sequences;
        } else {
            sequences.push(differences(&last));
        }
    }
}

fn differences(sequence: &Vec<isize>) -> Vec<isize> {
    sequence
        .windows(2)
        .map(|slice| match slice {
            &[n1, n2] => n2 - n1,
            _ => 0,
        })
        .collect::<Vec<isize>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
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
