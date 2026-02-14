use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

type Ranges = Input;

impl Ranges {
    fn invalid_sum(&self, condition: fn(&i64) -> bool) -> i64 {
        self.data.split(",").fold(0, |acc, range| {
            let parts = range
                .split("-")
                .map(|part| part.parse::<i64>().unwrap())
                .collect::<Vec<i64>>();
            acc + (parts[0]..=parts[1]).filter(condition).sum::<i64>()
        })
    }
}

fn part_one(input: &Input) -> i64 {
    input.invalid_sum(|id| is_invalid(id, true))
}

fn part_two(input: &Input) -> i64 {
    input.invalid_sum(|id| is_invalid(id, false))
}

fn is_invalid(id: &i64, restricted: bool) -> bool {
    let id_str = id.to_string();
    if restricted {
        id_str.len().is_multiple_of(2) && is_repeated(&id_str, id_str.len() / 2)
    } else {
        (1..=id_str.len() / 2).any(|window| is_repeated(&id_str, window))
    }
}

fn is_repeated(id: &str, window: usize) -> bool {
    match id.len() % window {
        0 => {
            let slice = &id[..window];
            (1..id.len() / window).all(|idx| &id[idx * window..(idx + 1) * window] == slice)
        }
        _ => false,
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            11-22,95-115,998-1012,1188511880-1188511890,222220-222224,\
            1698522-1698528,446443-446449,38593856-38593862,565653-565659,\
            824824821-824824827,2121212118-2121212124",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 1227775554);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 4174379265);
    }
}
