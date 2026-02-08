use crate::point::{Direction, Point};

#[derive(Debug, Copy, Clone, PartialEq)]
pub struct Line {
    src: Point,
    dir: Direction,
    len: i32,
}

impl Line {
    pub fn new(src: Point, dir: Direction, len: i32) -> Self {
        Line { src, dir, len }
    }

    pub fn src(&self) -> Point {
        self.src
    }

    pub fn dst(&self) -> Point {
        self.src + (self.len * Point::from(self.dir))
    }

    pub fn len(&self) -> i32 {
        self.len
    }

    pub fn is_vert(&self) -> bool {
        self.dir == Direction::Down || self.dir == Direction::Up
    }

    pub fn has_intersection(&self, rhs: &Self) -> bool {
        match (self.is_vert(), rhs.is_vert()) {
            (true, false) => {
                between(self.src.y, self.dst().y, rhs.src.y)
                    && between(rhs.src.x, rhs.dst().x, self.src.x)
            }
            (false, true) => {
                between(self.src.x, self.dst().x, rhs.src.x)
                    && between(rhs.src.y, rhs.dst().y, self.src.y)
            }
            _ => false,
        }
    }

    pub fn intersection(&self, rhs: &Self) -> Option<Point> {
        match (self.has_intersection(rhs), self.is_vert(), rhs.is_vert()) {
            (true, true, false) => Some(Point::new(self.src.x, rhs.src.y)),
            (true, false, true) => Some(Point::new(rhs.src.x, self.src.y)),
            _ => None,
        }
    }

    pub fn contains(&self, pt: &Point) -> bool {
        if self.is_vert() {
            self.src().x == pt.x && between(self.src().y, self.dst().y, pt.y)
        } else {
            self.src().y == pt.y && between(self.src().x, self.dst().x, pt.x)
        }
    }
}

fn between(a: i32, b: i32, target: i32) -> bool {
    if a <= b {
        a < target && target < b
    } else {
        b < target && target < a
    }
}
