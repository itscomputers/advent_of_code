use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn rotations(&self) -> Vec<i32> {
        self.data
            .lines()
            .map(|rotation| match rotation.chars().next() {
                Some('R') => (rotation[1..]).parse::<i32>().expect("not an integer"),
                Some('L') => -(rotation[1..]).parse::<i32>().expect("not an integer"),
                _ => panic!("unable to parse rotation `{rotation}`"),
            })
            .collect::<Vec<i32>>()
    }
}

fn part_one(input: &Input) -> i32 {
    input
        .rotations()
        .iter()
        .fold((50, 0), |acc, rot| {
            let value = i32::div_euclid(acc.0 + rot, 100);
            match value {
                0 => (value, acc.1 + 1),
                _ => (value, acc.1),
            }
        })
        .1
}

fn part_two(input: &Input) -> i32 {
    input
        .rotations()
        .iter()
        .fold((50, 0), |acc, rot| {
            let mut crossings = i32::div_euclid(acc.0 + rot, 100);
            let value = i32::rem_euclid(acc.0 + rot, 100);
            if acc.0 + rot <= 0 {
                crossings = -crossings;
                if acc.0 != 0 && value == 0 {
                    crossings += 1;
                } else if acc.0 == 0 && value != 0 {
                    crossings -= 1;
                }
            }
            (value, acc.1 + crossings)
        })
        .1
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            "\
            L68\n\
            L30\n\
            R48\n\
            L5\n\
            R60\n\
            L55\n\
            L1\n\
            L99\n\
            R14\n\
            L82",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 3);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 6);
    }
}
