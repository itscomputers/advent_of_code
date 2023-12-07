use std::collections::{HashMap, HashSet};
use std::fs::read_to_string;

use regex::Regex;

use itertools::Itertools;
use lazy_static::lazy_static;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/03.txt").unwrap();
}

pub fn main() {
    let symbol_lookup = symbol_lookup(&INPUT);
    let parts = parts(&INPUT, &symbol_lookup);
    let gear_ratios = gear_ratios(&parts, &symbol_lookup);
    println!("day 02");
    println!(
        "part 1: {}",
        parts.iter().map(|part| part.value).sum::<usize>()
    );
    println!("part 2: {}", gear_ratios.iter().sum::<usize>());
}

fn symbol_lookup(input: &str) -> HashMap<Loc, char> {
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

fn parts(input: &str, symbol_lookup: &HashMap<Loc, char>) -> HashSet<Part> {
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

fn gear_ratios(parts: &HashSet<Part>, symbol_lookup: &HashMap<Loc, char>) -> Vec<usize> {
    parts
        .iter()
        .filter(|part| {
            symbol_lookup.contains_key(&part.symbol_loc)
                && symbol_lookup.get(&part.symbol_loc).unwrap() == &'*'
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

#[cfg(test)]
mod tests {
    use super::*;

    lazy_static! {
        static ref TEST_INPUT: String = String::from(
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
            .664.598.."
        );
    }

    #[test]
    fn test_part_one() {
        let parts = parts(&TEST_INPUT, &symbol_lookup(&TEST_INPUT));
        assert_eq!(parts.iter().map(|part| part.value).sum::<usize>(), 4361);
    }

    #[test]
    fn test_part_two() {
        let ratios = gear_ratios(
            &parts(&TEST_INPUT, &symbol_lookup(&TEST_INPUT)),
            &symbol_lookup(&TEST_INPUT),
        );
        assert_eq!(ratios.iter().sum::<usize>(), 467835);
    }
}
