use std::collections::HashSet;

use crate::grid::Grid;
use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    Department::from(input).extractable().count()
}

fn part_two(input: &Input) -> usize {
    let mut department = Department::from(input);
    loop {
        let extractable = department.extractable().collect::<HashSet<_>>();
        if extractable.is_empty() {
            return department.extracted;
        }
        department = department.extract(extractable);
    }
}

struct Department {
    grid: Grid<char>,
    extracted: usize,
}

impl From<&Input> for Department {
    fn from(input: &Input) -> Self {
        Self {
            grid: Grid::from(input),
            extracted: 0,
        }
    }
}

impl Department {
    fn extractable(&self) -> impl Iterator<Item = &(i32, i32)> {
        self.grid.points().filter(|loc| self.can_extract(loc))
    }

    fn can_extract(&self, loc: &(i32, i32)) -> bool {
        self.grid.value(loc) == '@' && self.neighbor_count(loc) < 4
    }

    fn neighbor_count(&self, loc: &(i32, i32)) -> usize {
        self.grid
            .lax_neighbors(loc)
            .iter()
            .filter(|ch| ***ch == '@')
            .count()
    }

    fn extract(&self, locations: HashSet<&(i32, i32)>) -> Self {
        let grid = self.grid.with_update('.', |loc| locations.contains(loc));
        Self {
            grid,
            extracted: self.extracted + locations.len(),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            ..@@.@@@@.\n\
            @@@.@.@.@@\n\
            @@@@@.@.@@\n\
            @.@@@@..@.\n\
            @@.@@@@.@@\n\
            .@@@@@@@.@\n\
            .@.@.@.@@@\n\
            @.@@@.@@@@\n\
            .@@@@@@@@.\n\
            @.@.@@@.@.",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 13);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 43);
    }
}
