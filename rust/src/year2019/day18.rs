use std::collections::HashMap;

use crate::{
    graph::{
        bfs::Bfs,
        dijkstra::Dijkstra,
        traits::{Neighbors, Weighted},
    },
    grid::Grid,
    io::{Input, Solution},
    point::Point,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i32 {
    let vault = KeyVault::from(input);
    let key = vault.key;
    let mut dijkstra = Dijkstra::new(vault, KeyChar::new('@'));
    match dijkstra.traverse_until(|node| node.key == key) {
        Some(node) => *dijkstra.distance(&node).unwrap(),
        None => panic!("search unsuccessful"),
    }
}

fn part_two(input: &Input) -> i32 {
    let vault = KeyVault4::from(input);
    let key = vault.key;
    let mut dijkstra = Dijkstra::new(vault, KeyChars::new(['1', '2', '3', '4']));
    match dijkstra.traverse_until(|node| node.key == key) {
        Some(node) => *dijkstra.distance(&node).unwrap(),
        None => panic!("search unsuccessful"),
    }
}

struct Vault {
    grid: Grid<char>,
}

impl Vault {
    fn collapse(&self) -> HashMap<char, HashMap<char, i32>> {
        self.nodes()
            .iter()
            .fold(HashMap::new(), |mut acc, (pt, ch)| {
                acc.insert(*ch, self.distances(pt));
                acc
            })
    }

    fn distances(&self, source: &Point) -> HashMap<char, i32> {
        let mut bfs = Bfs::new(self, (*source, self.grid.value(&(source.x, source.y))));
        bfs.traverse();
        bfs.distances()
            .iter()
            .fold(HashMap::new(), |mut acc, (node, dist)| {
                let pt = node.0;
                let ch = self.grid.value(&(pt.x, pt.y));
                if ch == '@' || ch.is_ascii_alphanumeric() {
                    acc.insert(ch, *dist);
                }
                acc
            })
    }

    fn nodes(&self) -> Vec<(Point, char)> {
        self.grid
            .filter(|_, ch| *ch == '@' || ch.is_ascii_alphanumeric())
            .iter()
            .map(|(pt, ch)| (Point::from(*pt), **ch))
            .collect::<Vec<_>>()
    }

    fn entrance(&self) -> Point {
        self.grid
            .find(|_, ch| *ch == '@')
            .map(|((x, y), _)| Point::new(*x, *y))
            .unwrap()
    }
}

impl From<&Input> for Vault {
    fn from(input: &Input) -> Self {
        Self {
            grid: Grid::from(input),
        }
    }
}

impl Neighbors for &Vault {
    type Node = (Point, char);

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        let pt = node.0;
        let src = node.1;
        let ch = self.grid.value(&(pt.x, pt.y));
        if ch.is_ascii_alphanumeric() && ch != src {
            Vec::new()
        } else {
            pt.neighbors()
                .iter()
                .filter_map(|p| match self.grid.value(&(p.x, p.y)) {
                    '#' => None,
                    _ => Some((*p, src)),
                })
                .collect::<Vec<_>>()
        }
    }
}

struct KeyVault {
    vault: HashMap<char, HashMap<char, i32>>,
    key: Key,
}

impl From<&Input> for KeyVault {
    fn from(input: &Input) -> Self {
        let vault = Vault::from(input).collapse();
        let mut key = Key::new();
        for ch in vault.keys() {
            if ch.is_ascii_lowercase() {
                key = key.add(*ch);
            }
        }
        Self { vault, key }
    }
}

impl Neighbors for KeyVault {
    type Node = KeyChar;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        self.vault
            .neighbors(&node.value)
            .iter()
            .filter_map(|ch| node.unlock(*ch))
            .collect::<Vec<_>>()
    }
}

impl Weighted for KeyVault {
    type Node = KeyChar;

    fn weight(&self, source: &Self::Node, target: &Self::Node) -> Option<i32> {
        self.vault.weight(&source.value, &target.value)
    }
}

#[derive(Eq, PartialEq, Hash, Clone, Copy, Debug)]
struct KeyChar {
    value: char,
    key: Key,
}

impl KeyChar {
    fn new(value: char) -> Self {
        Self {
            value,
            key: Key::new(),
        }
    }

    fn build(value: char, key: Key) -> Self {
        Self { value, key }
    }

    fn unlock(&self, value: char) -> Option<Self> {
        if value.is_ascii_lowercase() {
            Some(KeyChar {
                value,
                key: self.key.add(value),
            })
        } else if value == '@' || value.is_ascii_uppercase() && self.key.unlocks(value) {
            Some(KeyChar {
                value,
                key: self.key,
            })
        } else {
            None
        }
    }
}

struct KeyVault4 {
    vault: HashMap<char, HashMap<char, i32>>,
    key: Key,
}

impl From<&Input> for KeyVault4 {
    fn from(input: &Input) -> Self {
        let mut vault = Vault::from(input);
        let entrance = vault.entrance();
        entrance.neighbors().iter().for_each(|pt| {
            vault.grid.set_value((pt.x, pt.y), '#');
        });
        vault.grid.set_value((entrance.x, entrance.y), '#');
        vault.grid.set_value((entrance.x - 1, entrance.y - 1), '1');
        vault.grid.set_value((entrance.x - 1, entrance.y + 1), '2');
        vault.grid.set_value((entrance.x + 1, entrance.y + 1), '3');
        vault.grid.set_value((entrance.x + 1, entrance.y - 1), '4');
        let vault = vault.collapse();
        let mut key = Key::new();
        for ch in vault.keys() {
            if ch.is_ascii_lowercase() {
                key = key.add(*ch);
            }
        }
        Self { vault, key }
    }
}

impl Neighbors for KeyVault4 {
    type Node = KeyChars;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        (0..4)
            .flat_map(|index| {
                self.vault
                    .neighbors(&node.node_at(index).value)
                    .iter()
                    .filter_map(|ch| node.node_at(index).unlock(*ch))
                    .map(|neighbor| node.with(index, &neighbor))
                    .collect::<Vec<_>>()
            })
            .collect::<Vec<_>>()
    }
}

impl Weighted for KeyVault4 {
    type Node = KeyChars;

    fn weight(&self, source: &Self::Node, target: &Self::Node) -> Option<i32> {
        let (a, b) = source.diff(target);
        self.vault.weight(&a, &b)
    }
}

#[derive(Eq, PartialEq, Hash, Clone, Copy, Debug)]
struct KeyChars {
    values: [char; 4],
    key: Key,
}

impl KeyChars {
    fn new(values: [char; 4]) -> Self {
        Self {
            values,
            key: Key::new(),
        }
    }

    fn diff(&self, other: &Self) -> (char, char) {
        (0..4)
            .find(|index| self.values[*index] != other.values[*index])
            .map(|index| (self.values[index], other.values[index]))
            .unwrap()
    }

    fn node_at(&self, index: usize) -> KeyChar {
        KeyChar {
            value: self.values[index],
            key: self.key,
        }
    }

    fn with(&self, index: usize, node: &KeyChar) -> Self {
        let values = match index {
            0 => [node.value, self.values[1], self.values[2], self.values[3]],
            1 => [self.values[0], node.value, self.values[2], self.values[3]],
            2 => [self.values[0], self.values[1], node.value, self.values[3]],
            3 => [self.values[0], self.values[1], self.values[2], node.value],
            _ => panic!("invalid index"),
        };
        Self {
            values,
            key: node.key,
        }
    }
}

#[derive(Clone, Copy, Debug, PartialEq, Eq, Hash)]
struct Key(i32);

impl Key {
    fn new() -> Self {
        Self(0)
    }

    fn unlocks(&self, door: char) -> bool {
        let exp = 1 << ((door as u8) + 32 - b'a');
        self.0 & exp == exp
    }

    fn add(&self, key: char) -> Key {
        let exp = 1 << ((key as u8) - b'a');
        Self(self.0 | exp)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_contains() {
        let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
        let mut key = Key::new();
        for door in alphabet.chars() {
            assert!(!key.unlocks(door));
        }
        key = key.add('c');
        key = key.add('a');
        key = key.add('t');
        key = key.add('s');
        for door in alphabet.chars() {
            assert_eq!(key.unlocks(door), ['C', 'A', 'T', 'S'].contains(&door));
        }
    }

    #[test]
    fn test_collapse() {
        let input = Input::from(
            "###############\n\
            #d.ABC.#.....a#\n\
            ######...######\n\
            ######.@.######\n\
            ######...######\n\
            #b.....#.....c#\n\
            ###############",
        );
        let vault = Vault::from(&input);
        assert_eq!(
            vault.collapse(),
            HashMap::from([
                (
                    '@',
                    HashMap::from([('@', 0), ('a', 8), ('b', 8), ('c', 8), ('C', 4)]),
                ),
                (
                    'a',
                    HashMap::from([('@', 8), ('a', 0), ('b', 16), ('c', 14), ('C', 10)]),
                ),
                (
                    'b',
                    HashMap::from([('@', 8), ('a', 16), ('b', 0), ('c', 14), ('C', 10)]),
                ),
                (
                    'c',
                    HashMap::from([('@', 8), ('a', 14), ('b', 14), ('c', 0), ('C', 12)]),
                ),
                ('d', HashMap::from([('d', 0), ('A', 2)])),
                ('A', HashMap::from([('d', 2), ('A', 0), ('B', 1)])),
                ('B', HashMap::from([('A', 1), ('B', 0), ('C', 1)])),
                (
                    'C',
                    HashMap::from([
                        ('@', 4),
                        ('a', 10),
                        ('b', 10),
                        ('c', 12),
                        ('B', 1),
                        ('C', 0)
                    ]),
                ),
            ])
        );
    }

    #[test]
    fn test_part_one() {
        let input = Input::from(
            "########################\n\
            #f.D.E.e.C.b.A.@.a.B.c.#\n\
            ######################.#\n\
            #d.....................#\n\
            ########################",
        );
        assert_eq!(part_one(&input), 86);
    }

    #[test]
    fn test_part_two() {
        let input = Input::from(
            "###############\n\
            #d.ABC.#.....a#\n\
            ######...######\n\
            ######.@.######\n\
            ######...######\n\
            #b.....#.....c#\n\
            ###############",
        );
        assert_eq!(part_two(&input), 24);
    }
}
