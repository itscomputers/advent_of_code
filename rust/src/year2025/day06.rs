use itertools::Itertools;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    ProblemSet::from(input).total(false)
}

fn part_two(input: &Input) -> i64 {
    ProblemSet::from(input).total(true)
}

struct ProblemSet {
    rows: Vec<Vec<String>>,
    ops: Vec<char>,
}

impl ProblemSet {
    fn total(&self, col: bool) -> i64 {
        (0..self.ops.len()).map(|index| self.calc(index, col)).sum()
    }

    fn calc(&self, index: usize, col: bool) -> i64 {
        match self.ops[index] {
            '+' => self.add(index, col),
            '*' => self.mult(index, col),
            _ => panic!("unexpected operator"),
        }
    }

    fn values(&self, index: usize, col: bool) -> Box<dyn Iterator<Item = i64> + '_> {
        if col {
            let matrix = self.char_matrix(index);
            let iter = (0..matrix[0].len()).map(move |col| {
                (0..matrix.len())
                    .map(|row| matrix[row][col])
                    .join("")
                    .trim()
                    .parse::<i64>()
                    .unwrap()
            });
            Box::new(iter)
        } else {
            let iter = self
                .rows
                .iter()
                .map(move |row| row[index].trim().parse::<i64>().unwrap());
            Box::new(iter)
        }
    }

    fn char_matrix(&self, index: usize) -> Vec<Vec<char>> {
        self.rows
            .iter()
            .map(|row| row[index].chars().collect::<Vec<_>>())
            .collect::<Vec<_>>()
    }

    fn add(&self, index: usize, col: bool) -> i64 {
        self.values(index, col).sum()
    }

    fn mult(&self, index: usize, col: bool) -> i64 {
        self.values(index, col).product()
    }
}

impl From<&Input> for ProblemSet {
    fn from(input: &Input) -> Self {
        let last = input.last(1).data;
        let mut indices = last
            .char_indices()
            .filter(|(_, ch)| *ch != ' ')
            .map(|(index, _)| index)
            .collect::<Vec<_>>();
        indices.push(last.len() + 1);
        let ops = last.chars().filter(|ch| *ch != ' ').collect::<Vec<_>>();
        let rows = input.drop_last(1).transform_lines(|line| {
            indices
                .iter()
                .tuple_windows()
                .map(|(i1, i2)| line[*i1..*i2 - 1].to_string())
                .collect::<Vec<_>>()
        });
        Self { rows, ops }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            [
                "123 328  51 64 ",
                " 45 64  387 23 ",
                "  6 98  215 314",
                "*   +   *   +  \n",
            ]
            .join("\n")
            .as_str(),
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 4277556);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 3263827);
    }
}
