use std::{fmt::Display, str::FromStr};

use itertools::Itertools;

use crate::{
    io::{Input, Solution},
    parser,
    range::InclRange,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    Floor::from(input).max_area()
}

fn part_two(input: &Input) -> i64 {
    Floor::from(input).max_inner_area()
}

trait Includes<T> {
    fn includes(&self, value: T) -> bool;
}

// -------- Tile -------- //
#[derive(Debug, PartialEq)]
struct Tile {
    x: i64,
    y: i64,
}

impl Tile {
    fn new(x: i64, y: i64) -> Self {
        Self { x, y }
    }

    fn area(&self, rhs: &Tile) -> i64 {
        let dx = (self.x - rhs.x).abs() + 1;
        let dy = (self.y - rhs.y).abs() + 1;
        dx * dy
    }
}

impl Display for Tile {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "({}, {})", self.x, self.y)
    }
}

#[derive(Debug)]
struct ParseErr;

impl FromStr for Tile {
    type Err = ParseErr;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let values = parser::int_vec(s, ",");
        Ok(Self {
            x: values[0],
            y: values[1],
        })
    }
}

// -------- Edge -------- //
#[derive(Debug, Copy, Clone)]
enum Edge {
    Horiz { x: InclRange, y: i64 },
    Vert { x: i64, y: InclRange },
}

impl Edge {
    fn is_vert(&self) -> bool {
        match self {
            Edge::Horiz { .. } => false,
            Edge::Vert { .. } => true,
        }
    }
}

impl Includes<&Edge> for Edge {
    fn includes(&self, edge: &Edge) -> bool {
        match (self, edge) {
            (Edge::Horiz { .. }, Edge::Horiz { .. }) => false,
            (Edge::Vert { .. }, Edge::Vert { .. }) => false,
            (Edge::Horiz { x: hx, y: hy }, Edge::Vert { x: vx, y: vy }) => {
                hx.contains_proper(vx) && vy.contains_proper(hy)
            }
            (Edge::Vert { x: vx, y: vy }, Edge::Horiz { x: hx, y: hy }) => {
                hx.contains_proper(vx) && vy.contains_proper(hy)
            }
        }
    }
}

impl Display for Edge {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Edge::Horiz { x, y } => write!(f, "({}, {})", x, y),
            Edge::Vert { x, y } => write!(f, "({}, {})", x, y),
        }
    }
}

impl From<(&Tile, &Tile)> for Edge {
    fn from(pair: (&Tile, &Tile)) -> Self {
        if pair.0.x == pair.1.x {
            let x = pair.0.x;
            let y = if pair.0.y < pair.1.y {
                InclRange::new(pair.0.y, pair.1.y)
            } else {
                InclRange::new(pair.1.y, pair.0.y)
            };
            Edge::Vert { x, y }
        } else {
            let y = pair.0.y;
            let x = if pair.0.x < pair.1.x {
                InclRange::new(pair.0.x, pair.1.x)
            } else {
                InclRange::new(pair.1.x, pair.0.x)
            };
            Edge::Horiz { x, y }
        }
    }
}

// -------- Rectangle -------- //
#[derive(Debug)]
struct Rectangle {
    ll: Tile,
    ul: Tile,
    lr: Tile,
    ur: Tile,
}

impl Rectangle {
    fn x(&self) -> InclRange {
        InclRange::new(self.ll.x, self.lr.x)
    }

    fn y(&self) -> InclRange {
        InclRange::new(self.ll.y, self.ul.y)
    }

    fn area(&self) -> i64 {
        self.ll.area(&self.ur)
    }

    fn left(&self) -> Edge {
        Edge::Vert {
            x: self.ll.x,
            y: self.y(),
        }
    }

    fn right(&self) -> Edge {
        Edge::Vert {
            x: self.lr.x,
            y: self.y(),
        }
    }

    fn lower(&self) -> Edge {
        Edge::Horiz {
            x: self.x(),
            y: self.ll.y,
        }
    }

    fn upper(&self) -> Edge {
        Edge::Horiz {
            x: self.x(),
            y: self.ul.y,
        }
    }

    fn one_dim(&self) -> bool {
        self.ll.x == self.lr.x || self.ll.y == self.ul.y
    }

    fn corners(&self) -> Vec<&Tile> {
        vec![&self.ll, &self.lr, &self.ul, &self.ur]
    }
}

impl Display for Rectangle {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "Rect<x: {}, y: {}>", self.x(), self.y())
    }
}

impl From<&(&Tile, &Tile)> for Rectangle {
    fn from(pair: &(&Tile, &Tile)) -> Self {
        let t1 = Tile::new(pair.0.x, pair.0.y);
        let t2 = Tile::new(pair.1.x, pair.1.y);
        let t3 = Tile::new(t1.x, t2.y);
        let t4 = Tile::new(t2.x, t1.y);
        let (ll, ul, lr, ur) = match (t1.x <= t2.x, t1.y <= t2.y) {
            (true, true) => (t1, t3, t4, t2),
            (true, false) => (t3, t1, t2, t4),
            (false, true) => (t4, t2, t1, t3),
            (false, false) => (t2, t4, t3, t1),
        };
        Self { ll, ul, lr, ur }
    }
}

// -------- Floor -------- //
#[derive(Debug)]
struct Floor {
    tiles: Vec<Tile>,
    edges: FloorEdges,
}

#[derive(Debug)]
struct FloorEdges {
    vert: Vec<Edge>,
    horiz: Vec<Edge>,
}

impl Floor {
    fn max_area(&self) -> i64 {
        self.tiles
            .iter()
            .tuple_combinations()
            .map(|(p1, p2)| p1.area(p2))
            .max()
            .unwrap()
    }

    fn max_inner_area(&self) -> i64 {
        self.tiles
            .iter()
            .tuple_combinations()
            .map(|(p1, p2)| Rectangle::from(&(p1, p2)))
            .filter(|rect| self.includes(rect))
            .map(|rect| rect.area())
            .max()
            .unwrap()
    }
}

impl Includes<&Tile> for Floor {
    fn includes(&self, tile: &Tile) -> bool {
        let (crossings, corners) = self.edges.vert.iter().fold((0, 0), |acc, edge| match edge {
            Edge::Horiz { .. } => acc,
            Edge::Vert { x, y } => {
                match (x <= &tile.x && y.contains(&tile.y), y.has_boundary(&tile.y)) {
                    (false, _) => acc,
                    (true, false) => (acc.0 + 1, acc.1),
                    (true, true) => (acc.0 + 1, acc.1 + 1),
                }
            }
        });
        (crossings + corners / 2) % 2 == 1
    }
}

impl Includes<&Rectangle> for Floor {
    fn includes(&self, rect: &Rectangle) -> bool {
        rect.corners().iter().all(|tile| self.includes(*tile))
            && self
                .edges
                .vert
                .iter()
                .all(|e| !rect.lower().includes(e) && !rect.upper().includes(e))
            && self
                .edges
                .horiz
                .iter()
                .all(|e| !rect.left().includes(e) && !rect.right().includes(e))
    }
}

impl From<&Input> for Floor {
    fn from(input: &Input) -> Self {
        let tiles = input.transform_lines(|line| Tile::from_str(line).unwrap());
        let mut vert = Vec::new();
        let mut horiz = Vec::new();
        for (index, tile) in tiles.iter().enumerate() {
            let edge = Edge::from((tile, &tiles[(index + 1) % tiles.len()]));
            if edge.is_vert() {
                vert.push(edge);
            } else {
                horiz.push(edge);
            }
        }

        Self {
            tiles,
            edges: FloorEdges { horiz, vert },
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            7,1\n\
            11,1\n\
            11,7\n\
            9,7\n\
            9,5\n\
            2,5\n\
            2,3\n\
            7,3\n\
            ",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 50);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 24);
    }
}
