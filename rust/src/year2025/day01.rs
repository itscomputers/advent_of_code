use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    let rotations = parse_rotations(input);
    Solution::build(part, &rotations, &part_one, &part_two)
}

fn part_one(rotations: &Vec<i32>) -> i32 {
    count_zeroes(rotations)
}

fn part_two(rotations: &Vec<i32>) -> i32 {
    count_crossings(rotations)
}

fn parse_rotations(input: &str) -> Vec<i32> {
    input
        .trim()
        .split("\n")
        .map(|rotation| match rotation.chars().next() {
            Some('R') => (rotation[1..]).parse::<i32>().expect("not an integer"),
            Some('L') => -(rotation[1..]).parse::<i32>().expect("not an integer"),
            _ => panic!("unable to parse rotation `{rotation}`"),
        })
        .collect::<Vec<i32>>()
}

fn count_zeroes(rotations: &Vec<i32>) -> i32 {
    rotations.iter().fold([50, 0], |acc, rot| {
        let value = i32::div_euclid(acc[0] + rot, 100);
        match value {
            0 => [value, acc[1] + 1],
            _ => [value, acc[1]],
        }
    })[1]
}

fn count_crossings(rotations: &Vec<i32>) -> i32 {
    rotations.iter().fold([50, 0], |acc, rot| {
        let mut crossings = i32::div_euclid(acc[0] + rot, 100);
        let value = i32::rem_euclid(acc[0] + rot, 100);
        if acc[0] + rot <= 0 {
            crossings = -crossings;
            if acc[0] != 0 && value == 0 {
                crossings += 1;
            } else if acc[0] == 0 && value != 0 {
                crossings -= 1;
            }
        }
        [value, acc[1] + crossings]
    })[1]
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            L68\n\
            L30\n\
            R48\n\
            L5\n\
            R60\n\
            L55\n\
            L1\n\
            L99\n\
            R14\n\
            L82",
        )
    }

    fn rotations() -> Vec<i32> {
        parse_rotations(&input())
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&rotations()), 3);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&rotations()), 6);
    }
}
