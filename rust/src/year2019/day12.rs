use std::fmt::Display;

use regex::Regex;

use crate::{
    io::{Input, Solution},
    num::Lcm,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    energy(input, 1000)
}

fn part_two(input: &Input) -> i64 {
    System::from(input).period()
}

fn energy(input: &Input, steps: usize) -> i64 {
    let mut system = System::from(input);
    system.advance_by(steps);
    system.energy()
}

struct System {
    moons: Vec<Moon>,
    step: i64,
    periods: [i64; 3],
}

impl System {
    fn energy(&self) -> i64 {
        self.moons.iter().map(Moon::energy).sum()
    }

    fn advance_by(&mut self, steps: usize) {
        (0..steps).for_each(|_| self.step());
    }

    fn period(&mut self) -> i64 {
        while self.periods.contains(&0) {
            self.step();
        }
        self.periods.iter().fold(1, |acc, period| acc.lcm(period))
    }

    fn step(&mut self) {
        self.step += 1;
        self.update_velocities();
        self.update_positions();
        self.update_periods();
    }

    fn update_velocities(&mut self) {
        for i in 0..self.moons.len() {
            let mut moon = self.moons[i];
            self.update_velocity_for(&mut moon);
            self.moons[i] = moon;
        }
    }

    fn update_velocity_for(&self, moon: &mut Moon) {
        for other in &self.moons {
            moon.update_velocity(other);
        }
    }

    fn update_positions(&mut self) {
        for i in 0..self.moons.len() {
            let mut moon = self.moons[i];
            moon.update_position();
            self.moons[i] = moon;
        }
    }

    fn update_periods(&mut self) {
        (0..3).for_each(|i| self.update_period(i))
    }

    fn update_period(&mut self, index: usize) {
        if self.periods[index] == 0
            && self
                .moons
                .iter()
                .map(|moon| match index {
                    0 => moon.vx,
                    1 => moon.vy,
                    2 => moon.vz,
                    _ => panic!("invalid index"),
                })
                .all(|vel| vel == 0)
        {
            self.periods[index] = 2 * self.step;
        }
    }
}

impl Display for System {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "System\n  {}",
            self.moons
                .iter()
                .map(|moon| format!("{}", moon))
                .collect::<Vec<String>>()
                .join("\n  ")
        )
    }
}

impl From<&Input> for System {
    fn from(input: &Input) -> Self {
        let moons = input.transform_lines(Moon::new);
        let step = 0;
        let periods = [0, 0, 0];
        Self {
            moons,
            step,
            periods,
        }
    }
}

#[derive(Copy, Clone)]
struct Moon {
    x: i64,
    y: i64,
    z: i64,
    vx: i64,
    vy: i64,
    vz: i64,
}

impl Moon {
    fn new(line: &str) -> Self {
        let (_, [sx, sy, sz]) = Regex::new(r"\<x=(-?\d+), y=(-?\d+), z=(-?\d+)")
            .unwrap()
            .captures(line)
            .unwrap()
            .extract();
        Self {
            x: sx.parse::<i64>().unwrap(),
            y: sy.parse::<i64>().unwrap(),
            z: sz.parse::<i64>().unwrap(),
            vx: 0,
            vy: 0,
            vz: 0,
        }
    }

    fn potential(&self) -> i64 {
        self.x.abs() + self.y.abs() + self.z.abs()
    }

    fn kinetic(&self) -> i64 {
        self.vx.abs() + self.vy.abs() + self.vz.abs()
    }

    fn energy(&self) -> i64 {
        self.potential() * self.kinetic()
    }

    fn update_velocity(&mut self, other: &Moon) {
        match self.x.cmp(&other.x) {
            std::cmp::Ordering::Less => {
                self.vx += 1;
            }
            std::cmp::Ordering::Greater => {
                self.vx -= 1;
            }
            _ => {}
        }
        match self.y.cmp(&other.y) {
            std::cmp::Ordering::Less => {
                self.vy += 1;
            }
            std::cmp::Ordering::Greater => {
                self.vy -= 1;
            }
            _ => {}
        }
        match self.z.cmp(&other.z) {
            std::cmp::Ordering::Less => {
                self.vz += 1;
            }
            std::cmp::Ordering::Greater => {
                self.vz -= 1;
            }
            _ => {}
        }
    }

    fn update_position(&mut self) {
        self.x += self.vx;
        self.y += self.vy;
        self.z += self.vz;
    }
}

impl Display for Moon {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "pos=({}, {}, {}), vel=({}, {}, {})",
            self.x, self.y, self.z, self.vx, self.vy, self.vz
        )
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input1() -> Input {
        Input::from(
            "<x=-1, y=0, z=2>\n\
            <x=2, y=-10, z=-7>\n\
            <x=4, y=-8, z=8>\n\
            <x=3, y=5, z=-1>",
        )
    }

    fn input2() -> Input {
        Input::from(
            "<x=-8, y=-10, z=0>\n\
            <x=5, y=5, z=10>\n\
            <x=2, y=-7, z=3>\n\
            <x=9, y=-8, z=-3>",
        )
    }

    #[test]
    fn test_energy_1() {
        assert_eq!(energy(&input1(), 10), 179);
    }

    #[test]
    fn test_energy_2() {
        assert_eq!(energy(&input2(), 100), 1940);
    }

    #[test]
    fn test_part_two_1() {
        assert_eq!(part_two(&input1()), 2772);
    }

    #[test]
    fn test_part_two_2() {
        assert_eq!(part_two(&input2()), 4686774924);
    }
}
