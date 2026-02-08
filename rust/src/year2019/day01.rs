use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn fuel(&self) -> Vec<i32> {
        self.int_vec("\n")
    }

    fn total_fuel(&self, recursive: bool) -> i32 {
        self.fuel()
            .iter()
            .fold(0, |acc, val| acc + fuel_for(*val, recursive))
    }
}

fn part_one(input: &Input) -> i32 {
    input.total_fuel(false)
}

fn part_two(input: &Input) -> i32 {
    input.total_fuel(true)
}

fn fuel_for(value: i32, recursive: bool) -> i32 {
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

    fn input() -> Input {
        Input::from_str(
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
