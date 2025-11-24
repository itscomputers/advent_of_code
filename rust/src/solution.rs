use std::fmt;

#[derive(Default, Debug)]
pub struct Solution {
    part_one: Option<String>,
    part_two: Option<String>,
}

impl Solution {
    pub fn new(p1: String, p2: String) -> Solution {
        Solution {
            part_one: Some(p1),
            part_two: Some(p2),
        }
    }

    pub fn one(sol: String) -> Solution {
        Solution {
            part_one: Some(sol),
            part_two: None,
        }
    }

    pub fn two(sol: String) -> Solution {
        Solution {
            part_one: None,
            part_two: Some(sol),
        }
    }

    pub fn build<'a, T: fmt::Display, U>(
        part: &str,
        input: &'a U,
        p1: &dyn Fn(&'a U) -> T,
        p2: &dyn Fn(&'a U) -> T,
    ) -> Solution {
        match part {
            "1" => Solution::one(format!("{}", p1(input))),
            "2" => Solution::two(format!("{}", p2(input))),
            _ => Solution::new(format!("{}", p1(input)), format!("{}", p2(input))),
        }
    }
}

impl fmt::Display for Solution {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Solution {
                part_one: Some(p1),
                part_two: Some(p2),
            } => {
                write!(f, "1: {}\n2: {}", p1, p2)
            }
            Solution {
                part_one: Some(p1),
                part_two: None,
            } => {
                write!(f, "1: {}", p1)
            }
            Solution {
                part_one: None,
                part_two: Some(p2),
            } => {
                write!(f, "2: {}", p2)
            }
            _ => write!(f, "error: no solutions"),
        }
    }
}
