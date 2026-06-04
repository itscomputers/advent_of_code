pub trait Neighbors {
    type Node;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node>;
}
