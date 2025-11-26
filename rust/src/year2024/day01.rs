use crate::solution::Solution;

pub fn solve(part: &str, input: &String) -> Solution {
    let lists = get_lists(input);
    Solution::build(&part, &lists, &part_one, &part_two)
}

fn get_lists(input: &String) -> (Vec<i32>, Vec<i32>) {
    let mut v1 = Vec::new();
    let mut v2 = Vec::new();
    input.lines().for_each(|line| {
        match line
            .split_ascii_whitespace()
            .map(|s| s.parse::<i32>())
            .collect::<Vec<_>>()[..]
        {
            [Ok(a), Ok(b)] => {
                v1.push(a);
                v2.push(b);
            }
            _ => {}
        }
    });
    v1.sort();
    v2.sort();
    (v1, v2)
}

fn part_one(lists: &(Vec<i32>, Vec<i32>)) -> i32 {
    let (a, b) = lists;
    a.iter().zip(b).fold(0, |acc, (x, y)| acc + i32::abs(x - y))
}

fn part_two(lists: &(Vec<i32>, Vec<i32>)) -> i32 {
    let (a, b) = lists;
    a.iter().fold(0, |acc, value| {
        let mut index = 0;
        let mut count = 0;
        while index < b.len() && &b[index] < value {
            index = index + 1;
        }
        while index < b.len() && &b[index] == value {
            index = index + 1;
            count = count + 1;
        }
        acc + count * value
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> String {
        String::from(
            "\
            3   4\n\
            4   3\n\
            2   5\n\
            1   3\n\
            3   9\n\
            3   3",
        )
    }

    fn lists() -> (Vec<i32>, Vec<i32>) {
        get_lists(&input())
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&lists()), 11);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&lists()), 31);
    }
}
