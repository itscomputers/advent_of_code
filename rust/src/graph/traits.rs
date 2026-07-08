use std::collections::HashMap;

pub trait Neighbors {
    type Node;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node>;
}

impl Neighbors for HashMap<char, Vec<char>> {
    type Node = char;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        match self.get(node) {
            None => Vec::new(),
            Some(chars) => chars.clone(),
        }
    }
}

impl Neighbors for HashMap<char, HashMap<char, i32>> {
    type Node = char;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        match self.get(node) {
            None => Vec::new(),
            Some(edges) => edges
                .keys()
                .filter(|ch| ch != &node)
                .copied()
                .collect::<Vec<Self::Node>>(),
        }
    }
}

pub trait Weighted {
    type Node;

    fn weight(&self, source: &Self::Node, target: &Self::Node) -> Option<i32>;
}

impl Weighted for HashMap<char, HashMap<char, i32>> {
    type Node = char;

    fn weight(&self, source: &Self::Node, target: &Self::Node) -> Option<i32> {
        self.get(source)
            .and_then(|edges| edges.get(target))
            .copied()
    }
}
