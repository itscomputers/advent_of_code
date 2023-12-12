use lazy_static::lazy_static;
use std::fs::read_to_string;
use std::str::FromStr;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/04.txt").unwrap();
}

pub fn main() {
    println!("day 09");
    println!("part 1: {}", predict_sum(&INPUT, predict_right));
    println!("part 2: {}", predict_sum(&INPUT, predict_left));
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

    lazy_static! {
        static ref TEST_INPUT: String = String::from(
            "\
            0 3 6 9 12 15\n\
            1 3 6 10 15 21\n\
            10 13 16 21 30 45"
        );
    }

    #[test]
    fn test_part_one() {
        assert_eq!(predict_sum(&TEST_INPUT, predict_right), 114);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(predict_sum(&TEST_INPUT, predict_left), 2);
    }
}
