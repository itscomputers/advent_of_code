use std::{
    collections::{HashMap, HashSet, VecDeque},
    fmt::Display,
    ops::RangeInclusive,
};

#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq, PartialOrd, Ord)]
pub struct InclRange {
    lower: i64,
    upper: i64,
}

impl InclRange {
    pub fn new(lower: i64, upper: i64) -> Self {
        Self { lower, upper }
    }

    pub fn reduce<'a>(ranges: &'a [Self]) -> Vec<Self> {
        let graph = RangeGraph::from(ranges);
        let mut visited: HashSet<&'a InclRange> = HashSet::new();
        let mut components = Vec::new();
        for range in graph.connections.keys() {
            if !visited.contains(range) {
                let (component, contents) = graph.component(range);
                visited.extend(contents.iter());
                components.push(component);
            }
        }
        components
    }

    pub fn is_empty(&self) -> bool {
        self.lower > self.upper
    }

    pub fn contains(&self, value: &i64) -> bool {
        &self.lower <= value && value <= &self.upper
    }

    pub fn contains_proper(&self, value: &i64) -> bool {
        !self.has_boundary(value) && self.contains(value)
    }

    pub fn has_boundary(&self, value: &i64) -> bool {
        &self.lower == value || &self.upper == value
    }

    pub fn has_subrange(&self, range: &Self) -> bool {
        self.lower <= range.lower && range.upper <= self.upper
    }

    pub fn size(&self) -> i64 {
        self.upper - self.lower + 1
    }

    pub fn shift(&self, offset: &i64) -> Self {
        Self {
            lower: self.lower + offset,
            upper: self.upper + offset,
        }
    }

    pub fn extend(&mut self, value: &i64) {
        if self.is_empty() {
            self.lower = *value;
            self.upper = *value;
        } else if *value < self.lower {
            self.lower = *value;
        } else if *value > self.upper {
            self.upper = *value;
        }
    }

    pub fn intersect(&self, range: &Self) -> Self {
        Self {
            lower: self.lower.max(range.lower),
            upper: self.upper.min(range.upper),
        }
    }

    pub fn overlaps(&self, range: &Self) -> bool {
        self.lower <= range.upper && range.lower <= self.upper
            || self.upper + 1 == range.lower
            || self.lower == range.upper + 1
    }

    pub fn union(&self, range: &Self) -> Vec<Self> {
        if self.overlaps(range) {
            vec![self.overlapping_union(range)]
        } else if self <= range {
            vec![*self, *range]
        } else {
            vec![*range, *self]
        }
    }

    fn overlapping_union(&self, range: &Self) -> Self {
        Self {
            lower: self.lower.min(range.lower),
            upper: self.upper.max(range.upper),
        }
    }
}

impl Display for InclRange {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{}..={}", self.lower, self.upper)
    }
}

impl Default for InclRange {
    fn default() -> Self {
        Self {
            lower: 0,
            upper: -1,
        }
    }
}

impl From<&(i64, i64)> for InclRange {
    fn from(value: &(i64, i64)) -> Self {
        InclRange {
            lower: value.0,
            upper: value.1,
        }
    }
}

impl From<RangeInclusive<i64>> for InclRange {
    fn from(range: RangeInclusive<i64>) -> Self {
        let (lower, upper) = range.into_inner();
        Self { lower, upper }
    }
}

impl From<InclRange> for RangeInclusive<i64> {
    fn from(range: InclRange) -> Self {
        range.lower..=range.upper
    }
}

struct RangeGraph<'a> {
    connections: HashMap<&'a InclRange, Vec<&'a InclRange>>,
}

impl<'a> RangeGraph<'a> {
    fn component(&self, source: &'a InclRange) -> (InclRange, HashSet<&'a InclRange>) {
        let mut visited = HashSet::new();
        let mut component = *source;
        let mut frontier = VecDeque::new();
        frontier.push_back(source);
        while !frontier.is_empty() {
            if let Some(range) = frontier.pop_front() {
                if !visited.contains(range) {
                    visited.insert(range);
                    for neighbor in self.connections.get(range).unwrap() {
                        component = component.overlapping_union(neighbor);
                        frontier.push_back(neighbor);
                    }
                }
            }
        }
        (component, visited)
    }
}

impl<'a> From<&'a [InclRange]> for RangeGraph<'a> {
    fn from(ranges: &'a [InclRange]) -> Self {
        let mut connections = HashMap::new();
        for source in ranges {
            let mut neighbors = Vec::new();
            ranges
                .iter()
                .filter(|range| source.overlaps(range))
                .for_each(|range| {
                    neighbors.push(range);
                });
            connections.insert(source, neighbors);
        }
        Self { connections }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_contains() {
        let range = InclRange::new(-10, 10);
        for val in -10..=10 {
            assert!(range.contains(&val));
        }
        assert!(!range.contains(&-11));
        assert!(!range.contains(&11));
    }

    #[test]
    fn test_overlaps_subset() {
        let range = InclRange::new(0, 10);
        assert!(range.overlaps(&InclRange::new(3, 9)));
    }

    #[test]
    fn test_overlaps_superset() {
        let range = InclRange::new(3, 9);
        assert!(range.overlaps(&InclRange::new(0, 10)));
    }

    #[test]
    fn test_overlaps_intersection() {
        let r1 = InclRange::new(0, 10);
        let r2 = InclRange::new(5, 12);
        assert!(r1.overlaps(&r2));
        assert!(r2.overlaps(&r1));
    }

    #[test]
    fn test_overlaps_adjacent() {
        let r1 = InclRange::new(0, 10);
        let r2 = InclRange::new(11, 15);
        assert!(r1.overlaps(&r2));
        assert!(r2.overlaps(&r1));
    }

    #[test]
    fn test_overlaps_boundary_intersection() {
        let r1 = InclRange::new(0, 10);
        let r2 = InclRange::new(10, 15);
        assert!(r1.overlaps(&r2));
        assert!(r2.overlaps(&r1));
    }

    #[test]
    fn test_reduce_subrange() {
        let ranges = [
            InclRange::new(0, 10),
            InclRange::new(2, 7),
            InclRange::new(0, 3),
        ];
        assert_eq!(InclRange::reduce(&ranges), [InclRange::new(0, 10)]);
    }

    #[test]
    fn test_reduce_overlap() {
        let ranges = [
            InclRange::new(15, 25),
            InclRange::new(0, 10),
            InclRange::new(2, 17),
        ];
        assert_eq!(InclRange::reduce(&ranges), [InclRange::new(0, 25)]);
    }

    #[test]
    fn test_reduce_adjacent() {
        let ranges = [
            InclRange::new(0, 10),
            InclRange::new(17, 25),
            InclRange::new(11, 17),
        ];
        assert_eq!(InclRange::reduce(&ranges), [InclRange::new(0, 25)]);
    }

    #[test]
    fn test_reduce_disjoint() {
        let ranges = [
            InclRange::new(0, 10),
            InclRange::new(20, 25),
            InclRange::new(12, 17),
        ];
        let reduction = InclRange::reduce(&ranges);
        for range in ranges {
            assert!(reduction.contains(&range));
        }
    }

    #[test]
    fn test_conversions() {
        assert_eq!(RangeInclusive::from(InclRange::new(5, 10)), 5..=10);
        assert_eq!(InclRange::from(5..=10), InclRange::new(5, 10));
    }
}
