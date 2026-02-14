use std::ops::{Add, Mul, Neg, Sub};

#[derive(Debug, Copy, Clone, PartialEq)]
pub struct Point {
    pub x: i32,
    pub y: i32,
}

#[derive(Debug, Copy, Clone, PartialEq)]
pub enum Direction {
    Right,
    Down,
    Left,
    Up,
}

impl Point {
    pub fn new(x: i32, y: i32) -> Self {
        Self { x, y }
    }

    pub fn norm(&self) -> i32 {
        i32::abs(self.x) + i32::abs(self.y)
    }

    pub fn neighbors(&self) -> [Self; 4] {
        [
            self + &Point { x: 1, y: 0 },
            self + &Point { x: 0, y: 1 },
            self + &Point { x: -1, y: 0 },
            self + &Point { x: 0, y: -1 },
        ]
    }

    pub fn lax_neighbors(&self) -> [Self; 8] {
        [
            self + &Point { x: 1, y: 0 },
            self + &Point { x: 0, y: 1 },
            self + &Point { x: -1, y: 0 },
            self + &Point { x: 0, y: -1 },
            self + &Point { x: 1, y: 1 },
            self + &Point { x: -1, y: 1 },
            self + &Point { x: 1, y: -1 },
            self + &Point { x: -1, y: -1 },
        ]
    }
}

impl From<&(i32, i32)> for Point {
    fn from(pair: &(i32, i32)) -> Self {
        Point {
            x: pair.0,
            y: pair.1,
        }
    }
}

impl From<Direction> for Point {
    fn from(direction: Direction) -> Self {
        match direction {
            Direction::Right => Self { x: 1, y: 0 },
            Direction::Down => Self { x: 0, y: 1 },
            Direction::Left => Self { x: -1, y: 0 },
            Direction::Up => Self { x: 0, y: -1 },
        }
    }
}

impl Add for Point {
    type Output = Self;

    fn add(self, rhs: Self) -> Self {
        Self {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

impl Add for &Point {
    type Output = Point;

    fn add(self, rhs: Self) -> Point {
        Point {
            x: self.x + rhs.x,
            y: self.y + rhs.y,
        }
    }
}

impl Neg for Point {
    type Output = Self;

    fn neg(self) -> Self {
        Self {
            x: -self.x,
            y: -self.y,
        }
    }
}

impl Sub for Point {
    type Output = Self;

    fn sub(self, rhs: Self) -> Self {
        self + (-rhs)
    }
}

impl Mul<i32> for Point {
    type Output = Self;

    fn mul(self, rhs: i32) -> Self {
        Self {
            x: self.x * rhs,
            y: self.y * rhs,
        }
    }
}

impl Mul<Point> for i32 {
    type Output = Point;

    fn mul(self, rhs: Point) -> Point {
        rhs * self
    }
}
