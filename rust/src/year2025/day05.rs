use crate::{
    io::{Input, Solution},
    parser,
    range::InclRange,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let fresh = Fresh::from(input);
    let available = Available::from(input);
    available
        .ids
        .iter()
        .fold(0, |acc, id| if fresh.contains(id) { acc + 1 } else { acc })
}

fn part_two(input: &Input) -> i64 {
    Fresh::from(input).ranges.iter().map(InclRange::size).sum()
}

struct Fresh {
    ranges: Vec<InclRange>,
}

impl Fresh {
    fn contains(&self, id: &i64) -> bool {
        self.ranges.iter().any(|range| range.contains(id))
    }
}

impl From<&Input> for Fresh {
    fn from(input: &Input) -> Self {
        if let Some(input) = input.blocks().first() {
            let ranges = input.transform_lines(|line| {
                let parts = parser::int_vec(line, "-");
                InclRange::from(&(parts[0], parts[1]))
            });
            let ranges = InclRange::reduce(&ranges);
            Self { ranges }
        } else {
            panic!("no first block");
        }
    }
}

struct Available {
    ids: Vec<i64>,
}

impl From<&Input> for Available {
    fn from(input: &Input) -> Self {
        if let Some(input) = input.blocks().last() {
            let ids = input.int_vec("\n");
            Self { ids }
        } else {
            panic!("no last block")
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from(
            "\
            3-5\n\
            10-14\n\
            16-20\n\
            12-18\n\
            \n\
            1\n\
            5\n\
            8\n\
            11\n\
            17\n\
            32",
        )
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 3);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(part_two(&input()), 14);
    }
}
