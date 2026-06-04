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
        while !self.terminated {
            self.step();
        }
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

    fn handle_edge(&mut self, node: N, neighbor: N) {
        if !self.distances.contains_key(&neighbor) {
            self.distances
                .insert(neighbor, self.distances.get(&node).unwrap() + 1);
            self.queue.push_back(neighbor);
        }
    }
}
