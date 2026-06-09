use std::collections::{HashMap, VecDeque};

use crate::{
    graph::{bfs::Bfs, traits::Neighbors},
    io::{Input, Solution},
    point::{Direction, Point},
    year2019::computer::{Computer, Program},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i32 {
    let mut explorer = Explorer::from(input);
    explorer.explore();
    *explorer.distance().unwrap()
}

fn part_two(input: &Input) -> i32 {
    let mut explorer = Explorer::from(input);
    explorer.explore();
    let mut bfs = Bfs::new(explorer.surface, explorer.oxygen.unwrap());
    bfs.traverse();
    *bfs.distances().values().max().unwrap()
}

struct Explorer {
    bots: VecDeque<RepairBot>,
    distances: HashMap<Point, i32>,
    surface: HashMap<Point, Status>,
    oxygen: Option<Point>,
    terminated: bool,
}

impl Explorer {
    fn explore(&mut self) {
        while !self.terminated {
            self.step();
        }
    }

    fn distance(&self) -> Option<&i32> {
        self.oxygen.and_then(|oxygen| self.distances.get(&oxygen))
    }

    fn step(&mut self) {
        match self.bots.pop_front() {
            None => {
                self.terminated = true;
            }
            Some(bot) => {
                if self
                    .surface
                    .get(&bot.location)
                    .is_some_and(Status::is_oxygen)
                {
                    self.oxygen = Some(bot.location);
                }
                for dir in Direction::all() {
                    let loc = bot.location + Point::from(dir);
                    if !self.distances.contains_key(&loc)
                        && !self.surface.get(&loc).is_some_and(Status::is_wall)
                    {
                        let mut neighbor = bot.clone();
                        match neighbor.step(dir) {
                            Status::Wall => {
                                self.surface.insert(loc, Status::Wall);
                            }
                            status => {
                                self.surface.insert(loc, status);
                                self.bots.push_back(neighbor);
                                self.distances
                                    .insert(loc, self.distances.get(&bot.location).unwrap() + 1);
                            }
                        }
                    }
                }
            }
        }
    }
}

impl From<&Input> for Explorer {
    fn from(input: &Input) -> Self {
        let bot = RepairBot::from(input);
        let mut distances = HashMap::new();
        let mut surface = HashMap::new();
        let mut bots = VecDeque::new();
        distances.insert(bot.location, 0);
        surface.insert(bot.location, Status::Open);
        bots.push_back(bot);
        Self {
            bots,
            distances,
            surface,
            oxygen: None,
            terminated: false,
        }
    }
}

impl Neighbors for HashMap<Point, Status> {
    type Node = Point;

    fn neighbors(&self, node: &Self::Node) -> Vec<Self::Node> {
        node.neighbors()
            .iter()
            .filter(|neighbor| !self.get(neighbor).is_some_and(Status::is_wall))
            .copied()
            .collect::<Vec<_>>()
    }
}

#[derive(Clone)]
struct RepairBot {
    computer: Computer,
    location: Point,
}

impl RepairBot {
    fn step(&mut self, dir: Direction) -> Status {
        let output = self.computer.io_loop(input(&dir));
        let status = Status::from(output);
        if !status.is_wall() {
            self.location = self.location + Point::from(dir);
        }
        status
    }
}

impl From<&Input> for RepairBot {
    fn from(input: &Input) -> Self {
        let program = Program::from(input);
        let computer = Computer::new(program);
        let location = Point::new(0, 0);
        Self { computer, location }
    }
}

fn input(dir: &Direction) -> i64 {
    match dir {
        Direction::Right => 4,
        Direction::Down => 2,
        Direction::Left => 3,
        Direction::Up => 1,
    }
}

#[derive(Clone, Copy, Debug, PartialEq)]
enum Status {
    Wall,
    Open,
    Oxygen,
}

impl Status {
    fn is_wall(&self) -> bool {
        self == &Status::Wall
    }

    fn is_oxygen(&self) -> bool {
        self == &Status::Oxygen
    }
}

impl From<i64> for Status {
    fn from(value: i64) -> Self {
        match value {
            0 => Status::Wall,
            1 => Status::Open,
            2 => Status::Oxygen,
            _ => panic!("invalid output code: {}", value),
        }
    }
}
