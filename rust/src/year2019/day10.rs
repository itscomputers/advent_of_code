use std::collections::HashSet;

use crate::{
    io::{Input, Solution},
    num::Gcd,
    parser,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i32 {
    AsteroidField::from(input).max_visibility().1
}

fn part_two(input: &Input) -> i32 {
    Vaporizer::from(input).vaporize(200)
}

struct AsteroidField {
    asteroids: HashSet<(i32, i32)>,
}

impl AsteroidField {
    fn is_visible(&self, a: &(i32, i32), b: &(i32, i32)) -> bool {
        a != b
            && pts_between(a, b)
                .iter()
                .all(|pt| !self.asteroids.contains(pt))
    }

    fn visible_count(&self, a: &(i32, i32)) -> i32 {
        self.asteroids.iter().fold(
            0,
            |acc, b| if self.is_visible(a, b) { acc + 1 } else { acc },
        )
    }

    fn max_visibility(&self) -> (&(i32, i32), i32) {
        self.asteroids
            .iter()
            .map(|a| (a, self.visible_count(a)))
            .max_by(|(_, v1), (_, v2)| v1.cmp(v2))
            .unwrap()
    }

    fn count_between(&self, a: &(i32, i32), b: &(i32, i32)) -> usize {
        pts_between(a, b)
            .iter()
            .filter(|pt| self.asteroids.contains(pt))
            .count()
    }
}

impl From<&Input> for AsteroidField {
    fn from(input: &Input) -> Self {
        let mut asteroids = HashSet::new();
        for (y, line) in input.data.lines().enumerate() {
            for x in parser::match_indices(line, '#') {
                asteroids.insert((as_i32(x), as_i32(y)));
            }
        }
        Self { asteroids }
    }
}

struct Vaporizer {
    field: AsteroidField,
    center: (i32, i32),
}

impl Vaporizer {
    fn ordered(&self) -> Vec<&(i32, i32)> {
        let mut asteroids = self
            .field
            .asteroids
            .iter()
            .filter(|a| *a != &self.center)
            .collect::<Vec<&(i32, i32)>>();
        asteroids.sort_by(|a1, a2| self.cmp(a1, a2));
        asteroids
    }

    fn cmp(&self, lhs: &(i32, i32), rhs: &(i32, i32)) -> std::cmp::Ordering {
        let lhw = self.field.count_between(&self.center, lhs);
        let rhw = self.field.count_between(&self.center, rhs);
        if lhw == rhw {
            cmp(&self.rel(lhs), &self.rel(rhs))
        } else {
            lhw.cmp(&rhw)
        }
    }

    fn vaporize(&self, index: usize) -> i32 {
        let asteroids = self.ordered();
        let pt = asteroids[index - 1];
        pt.0 * 100 + pt.1
    }

    fn rel(&self, pt: &(i32, i32)) -> (i32, i32) {
        (pt.0 - self.center.0, pt.1 - self.center.1)
    }
}

impl From<&Input> for Vaporizer {
    fn from(input: &Input) -> Self {
        let field = AsteroidField::from(input);
        let center = *field.max_visibility().0;
        Self { field, center }
    }
}

fn as_i32(index: usize) -> i32 {
    match i32::try_from(index) {
        Ok(i) => i,
        Err(_) => panic!("index too large"),
    }
}

fn cmp(lhs: &(i32, i32), rhs: &(i32, i32)) -> std::cmp::Ordering {
    let lhr = region(lhs);
    let rhr = region(rhs);
    if lhr == rhr {
        (rhs.0 * lhs.1).cmp(&(lhs.0 * rhs.1))
    } else {
        lhr.cmp(&rhr)
    }
}

fn region(pt: &(i32, i32)) -> i32 {
    if pt.0 == 0 {
        if pt.1 > 0 {
            4
        } else {
            0
        }
    } else if pt.0 > 0 {
        if pt.1 > 0 {
            3
        } else if pt.1 < 0 {
            1
        } else {
            2
        }
    } else if pt.1 > 0 {
        5
    } else if pt.1 < 0 {
        7
    } else {
        6
    }
}

fn pts_between(a: &(i32, i32), b: &(i32, i32)) -> Vec<(i32, i32)> {
    let dx = b.0 - a.0;
    let dy = b.1 - a.1;
    let d = dx.gcd(&dy);
    (1..d)
        .map(|i| (a.0 + i * dx / d, a.1 + i * dy / d))
        .collect::<Vec<_>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input1() -> Input {
        Input::from(
            ".#..#\n\
            .....\n\
            #####\n\
            ....#\n\
            ...##",
        )
    }

    fn input2() -> Input {
        Input::from(
            "......#.#.\n\
            #..#.#....\n\
            ..#######.\n\
            .#.#.###..\n\
            .#..#.....\n\
            ..#....#.#\n\
            #..#....#.\n\
            .##.#..###\n\
            ##...#..#.\n\
            .#....####",
        )
    }

    fn input3() -> Input {
        Input::from(
            "#.#...#.#.\n\
            .###....#.\n\
            .#....#...\n\
            ##.#.#.#.#\n\
            ....#.#.#.\n\
            .##..###.#\n\
            ..#...##..\n\
            ..##....##\n\
            ......#...\n\
            .####.###.",
        )
    }

    fn input4() -> Input {
        Input::from(
            ".#..#..###\n\
            ####.###.#\n\
            ....###.#.\n\
            ..###.##.#\n\
            ##.##.#.#.\n\
            ....###..#\n\
            ..#.#..#.#\n\
            #..#.#.###\n\
            .##...##.#\n\
            .....#.#..",
        )
    }

    fn input5() -> Input {
        Input::from(
            ".#..##.###...#######\n\
            ##.############..##.\n\
            .#.######.########.#\n\
            .###.#######.####.#.\n\
            #####.##.#.##.###.##\n\
            ..#####..#.#########\n\
            ####################\n\
            #.####....###.#.#.##\n\
            ##.#################\n\
            #####.##.###..####..\n\
            ..######..##.#######\n\
            ####.##.####...##..#\n\
            .#####..#.######.###\n\
            ##...#.##########...\n\
            #.##########.#######\n\
            .####.#.###.###.#.##\n\
            ....##.##.###..#####\n\
            .#.#.###########.###\n\
            #.#.#.#####.####.###\n\
            ###.##.####.##.#..##",
        )
    }

    fn input6() -> Input {
        Input::from(
            ".#....#####...#..\n\
            ##...##.#####..##\n\
            ##...#...#.#####.\n\
            ..#.....X...###..\n\
            ..#.#.....#....##",
        )
    }

    #[test]
    fn test_part_one_1() {
        assert_eq!(part_one(&input1()), 8);
    }

    #[test]
    fn test_part_one_2() {
        assert_eq!(part_one(&input2()), 33);
    }

    #[test]
    fn test_part_one_3() {
        assert_eq!(part_one(&input3()), 35);
    }

    #[test]
    fn test_part_one_4() {
        assert_eq!(part_one(&input4()), 41);
    }

    #[test]
    fn test_part_one_5() {
        assert_eq!(part_one(&input5()), 210);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input5()), 802);
    }

    #[test]
    fn test_vaporizer_a() {
        let vaporizer = Vaporizer::from(&input5());
        let ordered = vaporizer.ordered();
        for (i, pt) in [
            (1, (11, 12)),
            (2, (12, 1)),
            (3, (12, 2)),
            (10, (12, 8)),
            (20, (16, 0)),
            (50, (16, 9)),
            (100, (10, 16)),
            (199, (9, 6)),
            (200, (8, 2)),
            (201, (10, 9)),
            (299, (11, 1)),
        ] {
            assert_eq!(ordered[i - 1], &pt);
        }
    }

    #[test]
    fn test_vaporizer_b() {
        let vaporizer = Vaporizer {
            field: AsteroidField::from(&input6()),
            center: (8, 3),
        };
        assert_eq!(vaporizer.center, (8, 3));
        let ordered = vaporizer.ordered();
        assert_eq!(ordered[0], &(8, 1));
        assert_eq!(ordered[1], &(9, 0));
        assert_eq!(ordered[2], &(9, 1));
        assert_eq!(ordered[3], &(10, 0));
        assert_eq!(ordered[4], &(9, 2));
        assert_eq!(ordered[5], &(11, 1));
        assert_eq!(ordered[6], &(12, 1));
        assert_eq!(ordered[7], &(11, 2));
        assert_eq!(ordered[8], &(15, 1));
    }
}
