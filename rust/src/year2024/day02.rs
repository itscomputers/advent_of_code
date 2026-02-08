use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn count(&self, predicate: fn(&[i32]) -> bool) -> usize {
        self.data
            .lines()
            .map(|line| {
                line.split_ascii_whitespace()
                    .map(|s| s.parse::<i32>().unwrap())
                    .collect::<Vec<_>>()
            })
            .filter(|v| predicate(v.as_slice()))
            .count()
    }
}

fn part_one(input: &Input) -> usize {
    input.count(is_safe)
}

fn part_two(input: &Input) -> usize {
    input.count(is_almost_safe)
}

fn get_diff(report: &[i32]) -> Vec<i32> {
    let negative = report[1] - report[0] < 0;
    report
        .windows(2)
        .map(move |vals| {
            if negative {
                vals[0] - vals[1]
            } else {
                vals[1] - vals[0]
            }
        })
        .collect::<Vec<_>>()
}

fn is_safe(report: &[i32]) -> bool {
    get_diff(report).iter().all(|d| 0 < *d && *d < 4)
}

fn is_almost_safe(report: &[i32]) -> bool {
    (0..report.len()).any(|idx| is_safe(&[&report[..idx], &report[idx + 1..]].concat()))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from_str(
            "\
            7 6 4 2 1
            1 2 7 8 9
            9 7 6 2 1
            1 3 2 4 5
            8 6 4 4 1
            1 3 6 7 9",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 2);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 4);
    }
}
