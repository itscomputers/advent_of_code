use std::str::FromStr;

use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> isize {
    total_fuel(&input, false)
}

fn part_two(input: &String) -> isize {
    total_fuel(&input, true)
}

fn total_fuel(input: &String, recursive: bool) -> isize {
    input.lines().fold(0, |acc, s| {
        let value = isize::from_str(s).unwrap();
        acc + fuel_for(value, recursive)
    })
}

fn fuel_for(value: isize, recursive: bool) -> isize {
    let fuel = value / 3 - 2;
    if fuel < 0 {
        0
    } else if fuel == 0 || !recursive {
        fuel
    } else {
        fuel + fuel_for(fuel, recursive)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            12\n\
            14\n\
            1969\n\
            100756",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 2 + 2 + 654 + 33583);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 2 + 2 + 966 + 50346);
    }
}
