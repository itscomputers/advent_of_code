use std::collections::HashMap;

use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    Orbiter::from(input).total()
}

fn part_two(input: &Input) -> usize {
    Orbiter::from(input).distance("YOU", "SAN")
}

struct Orbiter {
    orbiters: HashMap<String, Vec<String>>,
    orbiting: HashMap<String, String>,
}

impl Orbiter {
    fn total(&self) -> usize {
        self.orbiters.keys().map(|obj| self.orbits(obj)).sum()
    }

    fn distance(self, obj1: &str, obj2: &str) -> usize {
        let a1 = self.ancestors(obj1);
        let a2 = self.ancestors(obj2);
        for (i, x) in a1.iter().enumerate() {
            if let Some((j, _)) = a2.iter().enumerate().find(|(_, y)| x == *y) {
                return i + j - 2;
            }
        }
        0
    }

    fn orbits(&self, obj: &str) -> usize {
        match self.orbiters.get(obj) {
            Some(orbiters) => orbiters
                .iter()
                .fold(0, |acc, orbiter| acc + 1 + self.orbits(orbiter)),
            None => 0,
        }
    }

    fn ancestors(&self, obj: &str) -> Vec<String> {
        match self.orbiting.get(obj) {
            Some(orbiting) => {
                let mut ancestors = self.ancestors(orbiting);
                ancestors.insert(0, obj.to_string());
                ancestors
            }
            None => vec![obj.to_string()],
        }
    }
}

impl From<&Input> for Orbiter {
    fn from(input: &Input) -> Self {
        let mut orbiters = HashMap::new();
        let mut orbiting = HashMap::new();
        for line in input.data.lines() {
            let parts = line.split(")").collect::<Vec<_>>();
            let source = parts[0];
            let target = parts[1];
            orbiting.insert(target.to_string(), source.to_string());
            orbiters
                .entry(source.to_string())
                .or_insert(Vec::new())
                .push(target.to_string());
        }
        Self { orbiters, orbiting }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "COM)B\n\
            B)C\n\
            C)D\n\
            D)E\n\
            E)F\n\
            B)G\n\
            G)H\n\
            D)I\n\
            E)J\n\
            J)K\n\
            K)L\
            ",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 42);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 0);
    }
}
