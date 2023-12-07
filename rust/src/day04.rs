use lazy_static::lazy_static;
use std::collections::{HashMap, HashSet};
use std::fs::read_to_string;

lazy_static! {
    static ref INPUT: String = read_to_string("inputs/04.txt").unwrap();
}

pub fn main() {
    let scratchers = build_scratchers(&INPUT);
    let counts = get_counts(&scratchers);
    println!("day 04");
    println!(
        "part 1: {}",
        scratchers.iter().map(|s| s.score()).sum::<isize>()
    );
    println!("part 2: {}", counts.values().sum::<usize>());
}

fn build_scratchers(input: &str) -> Vec<Scratcher> {
    input.lines().map(|line| build_scratcher(line)).collect()
}

fn get_counts(scratchers: &Vec<Scratcher>) -> HashMap<usize, usize> {
    let mut hashmap = HashMap::new();
    for index in 0..scratchers.len() {
        hashmap.insert(index, 1);
    }
    for (index, &ref scratcher) in scratchers.iter().enumerate() {
        for offset in 1..=scratcher.count {
            hashmap.insert(
                index + offset,
                hashmap.get(&(index + offset)).unwrap() + hashmap.get(&index).unwrap(),
            );
        }
    }
    hashmap
}

fn build_scratcher(line: &str) -> Scratcher {
    let [ref winners, ref numbers] = line
        .split(": ")
        .last()
        .unwrap()
        .split(" | ")
        .map(|s| s.split_ascii_whitespace().collect())
        .collect::<Vec<HashSet<&str>>>()[0..2]
    else {
        panic!("card needs both winners and numbers")
    };
    let count = winners.intersection(&numbers).count();
    Scratcher { count }
}

struct Scratcher {
    count: usize,
}

impl Scratcher {
    pub fn score(&self) -> isize {
        if self.count == 0 {
            0
        } else {
            2_isize.pow((self.count - 1) as u32)
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    lazy_static! {
        static ref TEST_INPUT: String = String::from(
            "\
            Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53\n\
            Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19\n\
            Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1\n\
            Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83\n\
            Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36\n\
            Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11\n\
        "
        );
    }

    #[test]
    fn test_part_one() {
        let scratchers = build_scratchers(TEST_INPUT.as_ref());
        assert_eq!(scratchers.iter().map(|s| s.score()).sum::<isize>(), 13);
    }

    #[test]
    fn test_part_two() {
        let scratchers = build_scratchers(TEST_INPUT.as_ref());
        let counts = get_counts(&scratchers);
        assert_eq!(counts.values().sum::<usize>(), 30);
    }
}
