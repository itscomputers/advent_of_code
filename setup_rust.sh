#!/bin/bash

printf -v day "%02d" $2
file="rust/src/year${1}/day${day}.rs"
code="use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i32 {
    0
}

fn part_two(input: &Input) -> i32 {
    0
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            \"\\
            \"
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 0);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 0);
    }
}"

mkdir -p "inputs/${1}"
mkdir -p "rust/src/year${1}"

if [ ! -f "${file}" ]; then
  echo "creating src file for year${1}/day${day}"

  touch $file
  echo "$code" > $file
fi
