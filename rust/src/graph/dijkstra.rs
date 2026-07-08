use std::collections::{BinaryHeap, HashMap, HashSet};
use std::hash::Hash;

use crate::graph::traits::{Neighbors, Weighted};

pub struct Dijkstra<G, N>
where
    N: PartialEq + Eq + Clone + Copy,
{
    graph: G,
    source: N,
    lookup: HashMap<N, DijkstraNode<N>>,
    queue: BinaryHeap<DijkstraNode<N>>,
    visited: HashSet<N>,
    terminated: bool,
}

impl<G, N> Dijkstra<G, N>
where
    G: Neighbors<Node = N> + Weighted<Node = N>,
    N: PartialEq + Eq + Hash + Clone + Copy + std::fmt::Debug,
{
    pub fn new(graph: G, source: N) -> Self {
        let mut lookup = HashMap::new();
        let mut queue = BinaryHeap::new();
        lookup.insert(source, DijkstraNode::source(source));
        queue.push(DijkstraNode::new(source));
        Self {
            graph,
            source,
            lookup,
            queue,
            visited: HashSet::new(),
            terminated: false,
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
        self.lookup.get(node).and_then(|dn| dn.distance.as_ref())
    }

    pub fn distances(&self) -> HashMap<N, i32> {
        self.lookup.iter().fold(HashMap::new(), |mut acc, (n, dn)| {
            if let Some(distance) = dn.distance {
                acc.insert(*n, distance);
            }
            acc
        })
    }

    fn dijkstra_node(&mut self, node: N) -> DijkstraNode<N> {
        *self.lookup.entry(node).or_insert(DijkstraNode::new(node))
    }

    fn step_until<F>(&mut self, predicate: F) -> Option<N>
    where
        F: Fn(&N) -> bool,
    {
        match self.queue.pop() {
            None => {
                self.terminated = true;
                None
            }
            Some(node) => {
                if predicate(&node.node) {
                    Some(node.node)
                } else {
                    self.visited.insert(node.node);
                    for neighbor in self.graph.neighbors(&node.node) {
                        self.handle_edge(&node.node, &neighbor);
                    }
                    None
                }
            }
        }
    }

    fn handle_edge(&mut self, node: &N, neighbor: &N) {
        if !self.visited.contains(neighbor) {
            if let Some(dijk_node) = self.lookup.get(node) {
                if let (Some(d), Some(w)) = (dijk_node.distance, self.graph.weight(node, neighbor))
                {
                    let mut dijk_neighbor = self.dijkstra_node(*neighbor);
                    if dijk_neighbor.update(d + w) {
                        self.queue.push(dijk_neighbor);
                        self.lookup.insert(*neighbor, dijk_neighbor);
                    }
                }
            }
        }
    }
}

#[derive(PartialEq, Eq, Clone, Copy)]
struct DijkstraNode<N>
where
    N: PartialEq + Eq,
{
    node: N,
    distance: Option<i32>,
}

impl<N> DijkstraNode<N>
where
    N: Eq,
{
    fn new(node: N) -> Self {
        Self {
            node,
            distance: None,
        }
    }

    fn source(node: N) -> Self {
        Self {
            node,
            distance: Some(0),
        }
    }

    fn update(&mut self, distance: i32) -> bool {
        match self.distance {
            None => {
                self.distance = Some(distance);
                true
            }
            Some(d) if distance < d => {
                self.distance = Some(distance);
                true
            }
            _ => false,
        }
    }
}

impl<N> PartialOrd for DijkstraNode<N>
where
    N: PartialEq + Eq,
{
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

impl<N> Ord for DijkstraNode<N>
where
    N: PartialEq + Eq,
{
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        match (self.distance, other.distance) {
            (Some(lhs), Some(rhs)) => rhs.cmp(&lhs),
            (None, None) => std::cmp::Ordering::Equal,
            (None, _) => std::cmp::Ordering::Less,
            (_, None) => std::cmp::Ordering::Greater,
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
        let mut dijkstra = Dijkstra::new(graph, 'a');
        dijkstra.traverse();
        assert_eq!(dijkstra.distance(&'b'), Some(&6));
        assert_eq!(dijkstra.distance(&'c'), Some(&3));
        assert_eq!(dijkstra.distance(&'d'), Some(&11));
        assert_eq!(dijkstra.distance(&'e'), Some(&2));
        assert_eq!(dijkstra.distance(&'f'), None);
    }

    #[test]
    fn test_traverse_until() {
        let graph = graph();
        let mut dijkstra = Dijkstra::new(graph, 'a');
        let target = dijkstra.traverse_until(|ch| *ch == 'b');
        assert_eq!(target, Some('b'));
        assert_eq!(dijkstra.distance(&'b'), Some(&6));
    }

    #[test]
    fn test_traverse_fail() {
        let graph = graph();
        let mut dijkstra = Dijkstra::new(graph, 'a');
        let target = dijkstra.traverse_until(|ch| *ch == 'f');
        assert_eq!(target, None);
        assert_eq!(dijkstra.distance(&'b'), Some(&6));
        assert_eq!(dijkstra.distance(&'c'), Some(&3));
        assert_eq!(dijkstra.distance(&'d'), Some(&11));
        assert_eq!(dijkstra.distance(&'e'), Some(&2));
        assert_eq!(dijkstra.distance(&'f'), None);
    }
}
