use std::ops::RangeInclusive;
use std::str::FromStr;

use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    let passwords = passwords(&input.trim().to_string());
    Solution::build(part, &passwords, &part_one, &part_two)
}

fn part_one(passwords: &Vec<Password>) -> usize {
    passwords.iter().filter(|&p| p.has_repeat()).count()
}

fn part_two(passwords: &Vec<Password>) -> usize {
    passwords.iter().filter(|&p| p.has_strict_repeat()).count()
}

fn range(input: &String) -> RangeInclusive<isize> {
    let bounds = input
        .split("-")
        .map(|s| isize::from_str(s).unwrap())
        .collect::<Vec<_>>();
    bounds[0]..=bounds[1]
}

fn passwords(input: &String) -> Vec<Password> {
    range(&input)
        .map(Password::new)
        .filter(Password::is_nondecreasing)
        .collect::<Vec<_>>()
}

#[derive(Debug, Default, PartialEq, Clone)]
struct Password {
    chars: Vec<char>,
}

impl Password {
    fn new(password: isize) -> Self {
        let chars = password.to_string().chars().collect::<Vec<_>>();
        Self { chars }
    }

    fn is_nondecreasing(&self) -> bool {
        (1..6).all(|idx| self.chars[idx - 1] <= self.chars[idx])
    }

    fn has_repeat(&self) -> bool {
        (1..6).any(|idx| self.chars[idx - 1] == self.chars[idx])
    }

    fn has_strict_repeat(&self) -> bool {
        (1..6).any(|idx| match idx {
            1 => self.chars[0] == self.chars[1] && self.chars[1] != self.chars[2],
            5 => self.chars[5] == self.chars[4] && self.chars[4] != self.chars[3],
            _ => {
                self.chars[idx] == self.chars[idx - 1]
                    && self.chars[idx] != self.chars[idx + 1]
                    && self.chars[idx] != self.chars[idx - 2]
            }
        })
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_password_111111() {
        let password = Password::new(111111);
        assert!(password.has_repeat());
        assert!(password.is_nondecreasing());
        assert!(!password.has_strict_repeat());
    }

    #[test]
    fn test_password_223450() {
        let password = Password::new(223450);
        assert!(password.has_repeat());
        assert!(!password.is_nondecreasing());
        assert!(password.has_strict_repeat());
    }

    #[test]
    fn test_password_123789() {
        let password = Password::new(123789);
        assert!(!password.has_repeat());
        assert!(password.is_nondecreasing());
        assert!(!password.has_strict_repeat());
    }

    #[test]
    fn test_password_112233() {
        let password = Password::new(112233);
        assert!(password.has_repeat());
        assert!(password.is_nondecreasing());
        assert!(password.has_strict_repeat());
    }

    #[test]
    fn test_password_123444() {
        let password = Password::new(123444);
        assert!(password.has_repeat());
        assert!(password.is_nondecreasing());
        assert!(!password.has_strict_repeat());
    }

    #[test]
    fn test_password_111122() {
        let password = Password::new(111122);
        assert!(password.has_repeat());
        assert!(password.is_nondecreasing());
        assert!(password.has_strict_repeat());
    }
}
