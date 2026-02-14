use regex::Regex;
use std::collections::{HashMap, HashSet};

use crate::io::{Input, Solution};

use itertools::Itertools;

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

type SchematicInput = Input;

impl SchematicInput {
    fn schematic(&self) -> Schematic {
        let symbols = self.symbols();
        let parts = self.parts(&symbols);
        Schematic { symbols, parts }
    }

    fn symbols(&self) -> HashMap<Loc, char> {
        let mut hashmap = HashMap::new();
        self.data.lines().enumerate().for_each(|(row, line)| {
            line.chars().enumerate().for_each(|(col, ch)| {
                if ch != '.' && !ch.is_ascii_digit() {
                    let loc = Loc { row, col };
                    hashmap.insert(loc, ch);
                }
            })
        });
        hashmap
    }

    fn parts(&self, symbols: &HashMap<Loc, char>) -> HashSet<Part> {
        let mut set = HashSet::new();
        let re = Regex::new(r"\d+").unwrap();
        self.data.lines().enumerate().for_each(|(row, line)| {
            for m in re.find_iter(line) {
                let value = m.as_str().parse::<u32>().unwrap();
                let mut neighbors = vec![(row, m.end())];
                if m.start() > 0 {
                    neighbors.push((row, m.start() - 1));
                }
                let start = if m.start() == 0 { 0 } else { m.start() - 1 };
                for c in start..=m.end() {
                    if row > 0 {
                        neighbors.push((row - 1, c));
                    }
                    neighbors.push((row + 1, c));
                }
                for (row, col) in neighbors {
                    let symbol_loc = Loc { row, col };
                    if symbols.contains_key(&symbol_loc) {
                        set.insert(Part { value, symbol_loc });
                        break;
                    }
                }
            }
        });
        set
    }
}

fn part_one(input: &Input) -> u32 {
    input
        .schematic()
        .parts
        .iter()
        .map(|part| part.value)
        .sum::<u32>()
}

fn part_two(input: &Input) -> u32 {
    input.schematic().gear_ratios().iter().sum::<u32>()
}

#[derive(Debug, Eq, PartialEq, Hash)]
struct Loc {
    row: usize,
    col: usize,
}

#[derive(Debug, Eq, PartialEq, Hash)]
struct Part {
    value: u32,
    symbol_loc: Loc,
}

#[derive(Debug)]
struct Schematic {
    symbols: HashMap<Loc, char>,
    parts: HashSet<Part>,
}

impl Schematic {
    fn gear_ratios(&self) -> Vec<u32> {
        self.parts
            .iter()
            .filter(|part| {
                self.symbols.contains_key(&part.symbol_loc)
                    && self.symbols.get(&part.symbol_loc).unwrap() == &'*'
            })
            .collect::<Vec<_>>()
            .iter()
            .combinations(2)
            .filter(|parts_| parts_[0].symbol_loc == parts_[1].symbol_loc)
            .map(|parts_| parts_[0].value * parts_[1].value)
            .collect()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            467..114..\n\
            ...*......\n\
            ..35..633.\n\
            ......#...\n\
            617*......\n\
            .....+.58.\n\
            ..592.....\n\
            ......755.\n\
            ...$.*....\n\
            .664.598..",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 4361);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 467835);
    }
}
