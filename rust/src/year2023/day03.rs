use regex::Regex;
use std::collections::{HashMap, HashSet};

use crate::solution::Solution;

use itertools::Itertools;

pub fn solve(part: &str, str_input: &String) -> Solution {
    let input = get_input(&str_input);
    Solution::build(part, &input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    input.parts.iter().map(|part| part.value).sum::<usize>()
}

fn part_two(input: &Input) -> usize {
    gear_ratios(&input).iter().sum::<usize>()
}

fn get_input(input: &String) -> Input {
    let symbols = get_symbols(&input);
    let parts = get_parts(&input, &symbols);
    Input { symbols, parts }
}

fn get_symbols(input: &str) -> HashMap<Loc, char> {
    let mut hashmap = HashMap::new();
    input.lines().enumerate().for_each(|(row, line)| {
        line.chars().enumerate().for_each(|(col, ch)| {
            if ch != '.' && !ch.is_ascii_digit() {
                hashmap.insert(Loc { row, col }, ch);
            }
        })
    });
    hashmap
}

fn get_parts(input: &str, symbol_lookup: &HashMap<Loc, char>) -> HashSet<Part> {
    let mut set = HashSet::new();
    let re = Regex::new(r"\d+").unwrap();
    input.lines().enumerate().for_each(|(row, line)| {
        for m in re.find_iter(&line) {
            let value = m.as_str().parse::<usize>().unwrap();
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
            for (r, c) in neighbors {
                let symbol_loc = Loc { row: r, col: c };
                if symbol_lookup.contains_key(&symbol_loc) {
                    set.insert(Part { value, symbol_loc });
                    break;
                }
            }
        }
    });
    set
}

fn gear_ratios(input: &Input) -> Vec<usize> {
    input
        .parts
        .iter()
        .filter(|part| {
            input.symbols.contains_key(&part.symbol_loc)
                && input.symbols.get(&part.symbol_loc).unwrap() == &'*'
        })
        .collect::<Vec<_>>()
        .iter()
        .combinations(2)
        .filter(|parts_| parts_[0].symbol_loc == parts_[1].symbol_loc)
        .map(|parts_| parts_[0].value * parts_[1].value)
        .collect()
}

#[derive(Debug, Eq, PartialEq, Hash)]
struct Loc {
    row: usize,
    col: usize,
}

#[derive(Debug, Eq, PartialEq, Hash)]
struct Part {
    value: usize,
    symbol_loc: Loc,
}

#[derive(Debug)]
struct Input {
    symbols: HashMap<Loc, char>,
    parts: HashSet<Part>,
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        get_input(&String::from(
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
        ))
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
