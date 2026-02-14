use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

type LocationsInput = Input;

impl LocationsInput {
    fn lists(&self) -> (Vec<i32>, Vec<i32>) {
        let mut v1 = Vec::new();
        let mut v2 = Vec::new();
        self.data.lines().for_each(|line| {
            let values = line
                .split_ascii_whitespace()
                .map(|s| s.parse::<i32>().unwrap())
                .collect::<Vec<i32>>();
            v1.push(values[0]);
            v2.push(values[1]);
        });
        v1.sort();
        v2.sort();
        (v1, v2)
    }
}

fn part_one(input: &Input) -> i32 {
    let (a, b) = input.lists();
    a.iter().zip(b).fold(0, |acc, (x, y)| acc + i32::abs(x - y))
}

fn part_two(input: &Input) -> i32 {
    let (a, b) = input.lists();
    a.iter().fold(0, |acc, value| {
        let mut index = 0;
        let mut count = 0;
        while index < b.len() && &b[index] < value {
            index += 1;
        }
        while index < b.len() && &b[index] == value {
            index += 1;
            count += 1;
        }
        acc + count * value
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            3   4\n\
            4   3\n\
            2   5\n\
            1   3\n\
            3   9\n\
            3   3",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 11);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 31);
    }
}
