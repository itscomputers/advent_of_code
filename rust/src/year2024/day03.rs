use itertools::Itertools;
use regex::Regex;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn eval(&self) -> i32 {
        Regex::new(r"mul\((\d\d?\d?),(\d\d?\d?)\)")
            .unwrap()
            .captures_iter(&self.data)
            .map(|c| {
                let (_, [a, b]) = c.extract();
                (a.parse::<i32>().unwrap(), b.parse::<i32>().unwrap())
            })
            .fold(0, |acc, (a, b)| acc + a * b)
    }

    fn pre_process(&self) -> Self {
        let data = self
            .data
            .split("do()")
            .map(|block| block.split("don't()").next().unwrap())
            .join("");
        Input { data }
    }
}

fn part_one(input: &Input) -> i32 {
    input.eval()
}

fn part_two(input: &Input) -> i32 {
    input.pre_process().eval()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_part_one() {
        let input = Input::from_str(
            "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))",
        );
        assert_eq!(part_one(&input), 161);
    }

    #[test]
    fn test_part_two() {
        let input = Input::from_str(
            "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))",
        );
        assert_eq!(part_two(&input), 48);
    }
}
