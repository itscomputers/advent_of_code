use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> isize { 0 }
fn part_two(input: &String) -> isize { 0 }

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            test"
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
}
