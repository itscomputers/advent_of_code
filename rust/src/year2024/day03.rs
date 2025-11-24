use itertools::Itertools;
use regex::Regex;
use std::str::FromStr;

use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> isize {
    eval(&input)
}

fn eval(input: &String) -> isize {
    matches(&input).iter().fold(0, |acc, (a, b)| acc + a * b)
}

fn part_two(input: &String) -> isize {
    eval(&pre_process(&input))
}

fn matches(input: &String) -> Vec<(isize, isize)> {
    let pattern = Regex::new(r"mul\((\d\d?\d?),(\d\d?\d?)\)").unwrap();
    pattern
        .captures_iter(input)
        .map(|c| {
            let (_, [a, b]) = c.extract();
            (isize::from_str(a).unwrap(), isize::from_str(b).unwrap())
        })
        .collect::<Vec<_>>()
}

fn pre_process(input: &String) -> String {
    input
        .split("do()")
        .map(|block| block.split("don't()").next().unwrap())
        .join("")
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input =
            String::from("xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))");
        assert_eq!(part_one(&input), 161);
    }

    #[test]
    fn test_part_two() {
        let input = String::from(
            "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
        );
        assert_eq!(part_two(&input), 48);
    }
}
