use std::collections::HashMap;

use crate::{
    io::{Input, Solution},
    parser,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    Manifold::from(input).exec().split_count
}

fn part_two(input: &Input) -> usize {
    Manifold::from(input).exec().beam_count()
}

struct Manifold {
    splitters: Vec<Vec<usize>>,
    beams: HashMap<usize, usize>,
    row: usize,
    split_count: usize,
}

impl Manifold {
    fn beam_count(&self) -> usize {
        self.beams.values().sum()
    }

    fn exec(&mut self) -> &Self {
        while self.row < self.splitters.len() {
            self.next();
        }
        self
    }

    fn next(&mut self) {
        let splitters = self.splitters[self.row].clone();
        for index in splitters {
            if self.beams.contains_key(&index) {
                let count = *self.beams.get(&index).unwrap();
                for key in [index - 1, index, index + 1] {
                    if key == index {
                        self.beams.remove(&key);
                    } else {
                        self.beams
                            .entry(key)
                            .and_modify(|prev| *prev += count)
                            .or_insert(count);
                    }
                }
                self.split_count += 1;
            }
        }
        self.row += 1;
    }
}

impl From<&Input> for Manifold {
    fn from(input: &Input) -> Self {
        let row = 1;
        let split_count = 0;
        let splitters = input.transform_lines(|line| parser::match_indices(line, '^'));
        let beams = {
            let mut set = HashMap::new();
            for index in input.first(1).match_indices('S') {
                set.insert(index, 1);
            }
            set
        };
        Manifold {
            splitters,
            beams,
            row,
            split_count,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            ".......S.......\n\
             ...............\n\
             .......^.......\n\
             ...............\n\
             ......^.^......\n\
             ...............\n\
             .....^.^.^.....\n\
             ...............\n\
             ....^.^...^....\n\
             ...............\n\
             ...^.^...^.^...\n\
             ...............\n\
             ..^...^.....^..\n\
             ...............\n\
             .^.^.^.^.^...^.\n\
             ...............",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 21);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 40);
    }
}
