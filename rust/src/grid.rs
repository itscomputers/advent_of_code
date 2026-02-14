use std::collections::HashMap;

use crate::{io::Input, point::Point};

#[derive(Debug, Clone)]
pub struct Grid<V> {
    pub size: (i32, i32),
    pub lookup: HashMap<(i32, i32), V>,
}

impl<V: Default + Copy + Clone> Grid<V> {
    pub fn points(&self) -> impl Iterator<Item = &(i32, i32)> {
        self.lookup.keys()
    }

    pub fn value(&self, point: &(i32, i32)) -> V {
        match self.lookup.get(point) {
            Some(val) => *val,
            None => V::default(),
        }
    }

    pub fn neighbors(&self, point: &(i32, i32)) -> Vec<&V> {
        Point::from(point)
            .neighbors()
            .iter()
            .filter_map(|neighbor| self.lookup.get(&(neighbor.x, neighbor.y)))
            .collect::<Vec<&V>>()
    }

    pub fn lax_neighbors(&self, point: &(i32, i32)) -> Vec<&V> {
        Point::from(point)
            .lax_neighbors()
            .iter()
            .filter_map(|neighbor| self.lookup.get(&(neighbor.x, neighbor.y)))
            .collect::<Vec<&V>>()
    }

    pub fn with_update(&self, value: V, predicate: impl Fn(&(i32, i32)) -> bool) -> Self {
        let mut grid = self.clone();
        for (point, val) in grid.lookup.iter_mut() {
            if predicate(point) {
                *val = value;
            }
        }
        grid
    }

    fn set_height(&mut self, height: i32) {
        self.size = (self.size.0, height);
    }

    fn set_width(&mut self, width: i32) {
        self.size = (width, self.size.1);
    }

    fn set_value(&mut self, point: (i32, i32), value: V) {
        self.lookup.insert(point, value);
    }
}

impl<V> Default for Grid<V> {
    fn default() -> Self {
        Self {
            lookup: HashMap::new(),
            size: (0, 0),
        }
    }
}

impl From<&Input> for Grid<char> {
    fn from(input: &Input) -> Self {
        input
            .data
            .trim()
            .lines()
            .enumerate()
            .fold(Self::default(), |mut grid, (row, line)| {
                line.chars().enumerate().for_each(|(col, ch)| {
                    grid.set_width(col as i32);
                    grid.set_value((row as i32, col as i32), ch);
                });
                grid.set_height(row as i32);
                grid
            })
    }
}
