use std::collections::{BinaryHeap, HashMap, HashSet};

use itertools::Itertools;

use crate::{
    io::{Input, Solution},
    parser,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    consolidate(input, 1000)
}

fn part_two(input: &Input) -> usize {
    Junction::from(input).reduce()
}

fn consolidate(input: &Input, count: usize) -> usize {
    let mut junction = Junction::from(input);
    junction.consolidate(count).status()
}

#[derive(Clone, Copy, Debug, Eq, Hash, PartialEq)]
struct Vector {
    coords: (i32, i32, i32),
}

#[derive(Debug, Eq, PartialEq)]
struct Connection {
    vectors: (Vector, Vector),
    source: usize,
    target: usize,
    distance: u64,
}

struct Junction {
    heap: BinaryHeap<Connection>,
    circuits: HashMap<usize, usize>,
    lookup: HashMap<usize, HashSet<usize>>,
}

impl Junction {
    fn merge(&mut self, conn: Connection) {
        let c1 = *self.circuits.get(&conn.source).unwrap();
        let c2 = self.circuits.get(&conn.target).unwrap();
        if c1 != *c2 {
            let s2 = self.lookup.get(c2).unwrap().clone();
            self.lookup.remove(c2);
            self.lookup.entry(c1).and_modify(|e| {
                for v in s2 {
                    e.insert(v);
                    self.circuits.entry(v).and_modify(|e| *e = c1);
                }
            });
        }
    }

    fn consolidate(&mut self, count: usize) -> &Self {
        for _ in 0..count {
            if let Some(connection) = self.heap.pop() {
                self.merge(connection);
            }
        }
        self
    }

    fn reduce(&mut self) -> usize {
        let mut dist = 0;
        while self.lookup.len() > 1 {
            if let Some(connection) = self.heap.pop() {
                let (v1, v2) = connection.vectors;
                dist = (v1.coords.0 as usize) * (v2.coords.0 as usize);
                self.merge(connection);
            }
        }
        dist
    }

    fn status(&self) -> usize {
        self.lookup
            .values()
            .map(HashSet::len)
            .k_largest(3)
            .product()
    }
}

impl Vector {
    fn dst(&self, rhs: &Self) -> u64 {
        let x = ((self.coords.0 - rhs.coords.0) as f64) / 1000.0;
        let y = ((self.coords.1 - rhs.coords.1) as f64) / 1000.0;
        let z = ((self.coords.2 - rhs.coords.2) as f64) / 1000.0;
        let fdist = (x.powf(2.0) + y.powf(2.0) + z.powf(2.0)).sqrt() * 100000.0;
        fdist.floor() as u64
    }
}

impl Ord for Connection {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        u64::cmp(&self.distance, &other.distance).reverse()
    }
}

impl PartialOrd for Connection {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl From<&Vec<i32>> for Vector {
    fn from(value: &Vec<i32>) -> Self {
        Vector {
            coords: (value[0], value[1], value[2]),
        }
    }
}

impl From<&str> for Vector {
    fn from(s: &str) -> Self {
        let values = parser::int_vec(s, ",");
        let coords = (values[0], values[1], values[2]);
        Self { coords }
    }
}

impl From<&Input> for Junction {
    fn from(input: &Input) -> Self {
        let vectors = input.transform_lines(|line| Vector::from(line));
        let mut heap = BinaryHeap::new();
        let mut circuits = HashMap::new();
        let mut lookup = HashMap::new();
        for (source, target) in (0..vectors.len()).tuple_combinations() {
            let distance = vectors[source].dst(&vectors[target]);
            let conn = Connection {
                vectors: (vectors[source], vectors[target]),
                source,
                target,
                distance,
            };
            heap.push(conn);
            let source_set = {
                let mut set = HashSet::new();
                set.insert(source);
                set
            };
            let target_set = {
                let mut set = HashSet::new();
                set.insert(target);
                set
            };
            lookup.insert(source, source_set);
            lookup.insert(target, target_set);
        }
        for source in 0..vectors.len() {
            circuits.insert(source, source);
        }
        Self {
            heap,
            circuits,
            lookup,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            162,817,812\n\
            57,618,57\n\
            906,360,560\n\
            592,479,940\n\
            352,342,300\n\
            466,668,158\n\
            542,29,236\n\
            431,825,988\n\
            739,650,466\n\
            52,470,668\n\
            216,146,977\n\
            819,987,18\n\
            117,168,530\n\
            805,96,715\n\
            346,949,466\n\
            970,615,88\n\
            941,993,340\n\
            862,61,35\n\
            984,92,344\n\
            425,690,689\n\
            ",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(consolidate(&input(), 10), 40);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 25272);
    }
}
