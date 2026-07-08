use std::collections::{HashMap, VecDeque};
use std::hash::Hash;

use crate::graph::traits::Neighbors;

pub struct Bfs<G, N> {
    graph: G,
    source: N,
    distances: HashMap<N, i32>,
    queue: VecDeque<N>,
    terminated: bool,
}

impl<G, N> Bfs<G, N>
where
    G: Neighbors<Node = N>,
    N: Eq + Hash + Clone + Copy,
{
    pub fn new(graph: G, source: N) -> Self {
        let mut distances = HashMap::new();
        let mut queue = VecDeque::new();
        distances.insert(source, 0);
        queue.push_back(source);
        let terminated = false;
        Self {
            graph,
            source,
            distances,
            queue,
            terminated,
        }
    }

    pub fn traverse(&mut self) {
        self.traverse_until(|_| false);
    }

    pub fn traverse_until<F>(&mut self, predicate: F) -> Option<N>
    where
        F: Fn(&N) -> bool,
    {
        while !self.terminated {
            if let Some(node) = self.step_until(&predicate) {
                return Some(node);
            }
        }
        None
    }

    pub fn distance(&self, node: &N) -> Option<&i32> {
        self.distances.get(node)
    }

    pub fn distances(&self) -> &HashMap<N, i32> {
        &self.distances
    }

    fn step(&mut self) {
        match self.queue.pop_front() {
            None => {
                self.terminated = true;
            }
            Some(node) => {
                for neighbor in self.graph.neighbors(&node) {
                    self.handle_edge(node, neighbor);
                }
            }
        }
    }

    fn step_until<F>(&mut self, predicate: F) -> Option<N>
    where
        F: Fn(&N) -> bool,
    {
        match self.queue.pop_front() {
            None => {
                self.terminated = true;
                None
            }
            Some(node) => {
                if predicate(&node) {
                    Some(node)
                } else {
                    for neighbor in self.graph.neighbors(&node) {
                        self.handle_edge(node, neighbor);
                    }
                    None
                }
            }
        }
    }

    fn handle_edge(&mut self, node: N, neighbor: N) {
        if !self.distances.contains_key(&neighbor) {
            self.distances
                .insert(neighbor, self.distances.get(&node).unwrap() + 1);
            self.queue.push_back(neighbor);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    /// a -------9-------> b ----7----> d
    /// |\                 ^            ^
    /// | \                /           /
    /// 2  --5--> c ---3---           /
    /// |        / \                 /
    /// v       /   ----------8------
    /// e --1---
    fn graph() -> HashMap<char, HashMap<char, i32>> {
        HashMap::from([
            ('a', HashMap::from([('b', 9), ('c', 5), ('e', 2)])),
            ('b', HashMap::from([('d', 7)])),
            ('c', HashMap::from([('b', 3), ('d', 8)])),
            ('e', HashMap::from([('c', 1)])),
            ('f', HashMap::from([('a', 3), ('b', 4), ('c', 5)])),
        ])
    }

    #[test]
    fn test_traverse() {
        let graph = graph();
        let mut bfs = Bfs::new(graph, 'a');
        bfs.traverse();
        assert_eq!(bfs.distance(&'b'), Some(&1));
        assert_eq!(bfs.distance(&'c'), Some(&1));
        assert_eq!(bfs.distance(&'d'), Some(&2));
        assert_eq!(bfs.distance(&'e'), Some(&1));
        assert_eq!(bfs.distance(&'f'), None);
    }

    #[test]
    fn test_traverse_until() {
        let graph = graph();
        let mut bfs = Bfs::new(graph, 'a');
        let target = bfs.traverse_until(|ch| *ch == 'b');
        assert_eq!(target, Some('b'));
        assert_eq!(bfs.distance(&'b'), Some(&1));
    }

    #[test]
    fn test_traverse_fail() {
        let graph = graph();
        let mut bfs = Bfs::new(graph, 'a');
        let target = bfs.traverse_until(|ch| *ch == 'f');
        assert_eq!(target, None);
        assert_eq!(bfs.distance(&'b'), Some(&1));
        assert_eq!(bfs.distance(&'c'), Some(&1));
        assert_eq!(bfs.distance(&'d'), Some(&2));
        assert_eq!(bfs.distance(&'e'), Some(&1));
        assert_eq!(bfs.distance(&'f'), None);
    }
}
