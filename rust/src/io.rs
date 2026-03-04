use std::fmt;
use std::fs::read_to_string;
use std::str::FromStr;

use itertools::Itertools;

use crate::parser;

#[derive(Default, Debug)]
pub struct Input {
    pub data: String,
}

impl Input {
    pub fn build(year: &str, day: &str) -> Self {
        let filepath = format!("../inputs/{}/{}.txt", &year, &day);
        let data = read_to_string(&filepath)
            .unwrap_or_else(|_| panic!("could not find input file {filepath}"));
        Input { data }
    }

    pub fn int_vec<I>(&self, separator: &str) -> Vec<I>
    where
        I: FromStr,
        <I as FromStr>::Err: fmt::Debug,
    {
        parser::int_vec::<I>(&self.data, separator)
    }

    pub fn int_vec_lines<I>(&self, separator: &str) -> Vec<Vec<I>>
    where
        I: FromStr,
        <I as FromStr>::Err: fmt::Debug,
    {
        self.transform_lines(|line| parser::int_vec(line, separator))
    }

    pub fn transform_lines<T>(&self, func: impl Fn(&str) -> T) -> Vec<T> {
        self.data.trim().lines().map(func).collect::<Vec<T>>()
    }

    pub fn blocks(&self) -> Vec<Input> {
        self.data.split("\n\n").map(Input::from).collect::<Vec<_>>()
    }

    pub fn match_indices(&self, ch: char) -> Vec<usize> {
        parser::match_indices(&self.data, ch)
    }

    pub fn split_whitespace(&self) -> Vec<String> {
        self.data
            .split_ascii_whitespace()
            .map(|s| s.to_string())
            .collect::<Vec<_>>()
    }

    pub fn drop_last(&self, count: usize) -> Self {
        let data = self
            .data
            .rsplitn(count + 2, "\n")
            .nth(count + 1)
            .unwrap()
            .to_string();
        Self { data }
    }

    pub fn last(&self, count: usize) -> Self {
        let data = self
            .data
            .rsplitn(count + 2, "\n")
            .dropping(1)
            .take(count)
            .join("\n")
            .to_string();
        Self { data }
    }

    pub fn first(&self, count: usize) -> Self {
        let data = self
            .data
            .splitn(count + 1, "\n")
            .take(count)
            .join("\n")
            .to_string();
        Self { data }
    }
}

impl From<&str> for Input {
    fn from(s: &str) -> Self {
        Self {
            data: s.to_string(),
        }
    }
}

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

    pub fn build<'a, T: fmt::Display>(
        part: &str,
        input: &'a Input,
        p1: &dyn Fn(&'a Input) -> T,
        p2: &dyn Fn(&'a Input) -> T,
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
