use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    input
        .int_vec_lines("")
        .iter()
        .map(|bank| max_joltage(bank.as_slice(), 2))
        .sum()
}

fn part_two(input: &Input) -> i64 {
    input
        .int_vec_lines("")
        .iter()
        .map(|bank| max_joltage(bank.as_slice(), 12))
        .sum()
}

fn max_joltage(bank: &[i32], count: usize) -> i64 {
    let upper = bank.len() - count;
    let mut indices = vec![max_index(bank, 0, upper)];
    for i in 1..count {
        let last = indices.last().unwrap();
        indices.push(max_index(bank, *last + 1, upper + i));
    }
    indices
        .iter()
        .fold(0, |acc, idx| acc * 10 + (bank[*idx] as i64))
}

fn max_index(slice: &[i32], lower: usize, upper: usize) -> usize {
    let mut max = lower;
    for index in lower + 1..=upper {
        if slice[index] > slice[max] {
            max = index;
        }
    }
    max
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            987654321111111\n\
            811111111111119\n\
            234234234234278\n\
            818181911112111",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 357);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 3121910778619);
    }
}
