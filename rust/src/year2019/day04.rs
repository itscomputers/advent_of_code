use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

impl Input {
    fn passwords(&self) -> Vec<Password> {
        let bounds = self.int_vec("-");
        (bounds[0]..=bounds[1])
            .map(Password::new)
            .filter(Password::is_nondecreasing)
            .collect::<Vec<_>>()
    }
}

fn part_one(input: &Input) -> usize {
    input.passwords().iter().filter(|&p| p.has_repeat()).count()
}

fn part_two(input: &Input) -> usize {
    input
        .passwords()
        .iter()
        .filter(|&p| p.has_strict_repeat())
        .count()
}

#[derive(Debug, Default, PartialEq, Clone)]
struct Password {
    chars: Vec<char>,
}

impl Password {
    fn new(password: i32) -> Self {
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
