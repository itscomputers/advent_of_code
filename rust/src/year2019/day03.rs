use regex::Regex;
use std::str::FromStr;

use crate::line::Line;
use crate::point::{Direction, Point};
use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &String) -> isize {
    minimum_distance(&input, false)
}

fn part_two(input: &String) -> isize {
    minimum_distance(&input, true)
}

fn minimum_distance(input: &String, delay: bool) -> isize {
    let mut lines = input.lines();
    let w1 = Wire::new(lines.next().unwrap());
    let w2 = Wire::new(lines.next().unwrap());
    w1.minimum_distance(&w2, delay)
}

struct Wire {
    lines: Vec<Line>,
}

impl Wire {
    fn new(string: &str) -> Self {
        let pattern = Regex::new(r"(?<dir>[RDLU])(?<amt>\d+)").unwrap();
        let lines: Vec<Line> =
            pattern
                .captures_iter(string)
                .fold(Vec::new(), |mut acc, captures| {
                    let dir = match captures.name("dir").unwrap().as_str() {
                        "R" => Direction::Right,
                        "D" => Direction::Down,
                        "L" => Direction::Left,
                        "U" => Direction::Up,
                        _ => panic!("error parsing direction"),
                    };
                    let amt = isize::from_str(captures.name("amt").unwrap().as_str()).unwrap();
                    let last = acc.last();
                    let src = if last.is_some() {
                        last.unwrap().dst()
                    } else {
                        Point::new(0, 0)
                    };
                    acc.push(Line::new(src, dir, amt));
                    acc
                });
        Wire { lines }
    }

    fn intersections(&self, rhs: &Wire) -> Vec<Point> {
        self.lines.iter().fold(Vec::new(), |mut acc, l1| {
            rhs.lines.iter().for_each(|l2| match l1.intersection(l2) {
                Some(pt) => acc.push(pt),
                _ => {}
            });
            acc
        })
    }

    fn minimum_distance(&self, rhs: &Wire, delay: bool) -> isize {
        let intersections = self.intersections(&rhs);
        if delay {
            intersections
                .iter()
                .map(|pt| self.delay(pt) + rhs.delay(pt))
                .min()
                .unwrap()
        } else {
            intersections.iter().map(Point::norm).min().unwrap()
        }
    }

    fn delay(&self, pt: &Point) -> isize {
        let mut delay = 0;
        for line in self.lines.iter() {
            if line.contains(&pt) {
                return delay + (*pt - line.src()).norm();
            } else {
                delay += line.len()
            }
        }
        delay
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            R8,U5,L5,D3\n\
            U7,R6,D4,L4",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 6);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 30);
    }
}
