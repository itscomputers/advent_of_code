use std::ops::Range;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let mut v = input.int_vec("");
    for _ in 0..100 {
        v = fft(&v);
    }
    value(&v, 0..8)
}

fn part_two(input: &Input) -> i64 {
    let mut v = extended(&input.int_vec(""));
    for _ in 0..100 {
        v = running_sum(&v);
    }
    (0..8).fold(0, |acc, i| 10 * acc + v[v.len() - 1 - i])
}

fn fft(input: &[i64]) -> Vec<i64> {
    (0..input.len())
        .map(|index| ffti(input, index))
        .collect::<Vec<_>>()
}

fn ffti(input: &[i64], index: usize) -> i64 {
    if 2 * index > input.len() {
        input[index..].iter().sum::<i64>().abs() % 10
    } else {
        sum(input, ranges(index, input.len())).abs() % 10
    }
}

fn running_sum(input: &[i64]) -> Vec<i64> {
    input.iter().fold(Vec::new(), |mut acc, val| {
        match acc.last() {
            Some(s) => acc.push((s + val) % 10),
            None => acc.push(*val),
        }
        acc
    })
}

fn value(input: &[i64], range: Range<usize>) -> i64 {
    input[range].iter().fold(0, |acc, digit| 10 * acc + digit)
}

fn sum(input: &[i64], ranges: Vec<Range<usize>>) -> i64 {
    let mut value = 0;
    let mut sgn = 1;
    for range in ranges {
        value += sgn * partial_sum(input, range);
        sgn *= -1;
    }
    value
}

fn partial_sum(input: &[i64], range: Range<usize>) -> i64 {
    if range.end >= input.len() {
        input[range.start..].iter().sum()
    } else {
        input[range].iter().sum()
    }
}

fn ranges(index: usize, size: usize) -> Vec<Range<usize>> {
    let count = ceil_div(size - index, 2 * (index + 1));
    (0..count).map(|i| range(index, i)).collect::<Vec<_>>()
}

fn ceil_div(numerator: usize, denominator: usize) -> usize {
    let rem = numerator % denominator;
    if rem == 0 {
        numerator / denominator
    } else {
        numerator / denominator + 1
    }
}

fn range(index: usize, iteration: usize) -> Range<usize> {
    let lower = (index + 1) * (2 * iteration + 1) - 1;
    let upper = lower + index + 1;
    lower..upper
}

fn extended(input: &[i64]) -> Vec<i64> {
    let offset = value(input, 0..7) as usize;
    let len = 10000 * input.len() - offset;
    let mut v = Vec::new();
    let mut i = input.len() - 1;
    while v.len() < len {
        v.push(input[i]);
        if i == 0 {
            i = input.len() - 1;
        } else {
            i -= 1;
        }
    }
    v
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_ranges() {
        let mut values = Vec::new();
        for index in 0..3 {
            values.push(ranges(index, 16));
        }
        assert_eq!(
            values,
            vec![
                vec![0..1, 2..3, 4..5, 6..7, 8..9, 10..11, 12..13, 14..15],
                vec![1..3, 5..7, 9..11, 13..15],
                vec![2..5, 8..11, 14..17],
            ],
        )
    }

    #[test]
    fn test_fft() {
        let mut v = vec![1, 2, 3, 4, 5, 6, 7, 8];
        v = fft(&v);
        assert_eq!(v, vec![4, 8, 2, 2, 6, 1, 5, 8]);
        v = fft(&v);
        assert_eq!(v, vec![3, 4, 0, 4, 0, 4, 3, 8]);
        v = fft(&v);
        assert_eq!(v, vec![0, 3, 4, 1, 5, 5, 1, 8]);
        v = fft(&v);
        assert_eq!(v, vec![0, 1, 0, 2, 9, 4, 9, 8]);
    }

    #[test]
    fn test_part_one() {
        let input = Input::from("80871224585914546619083218645595");
        assert_eq!(part_one(&input), 24176176);
    }

    #[test]
    fn test_part_two() {
        let input = Input::from("03036732577212944063491565474664");
        assert_eq!(part_two(&input), 84462026);
    }
}
