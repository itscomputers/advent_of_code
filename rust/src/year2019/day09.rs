use crate::{
    io::{Input, Solution},
    year2019::computer::Program,
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    let mut program = Program::from((input, 1));
    program.run();
    program.output().unwrap()
}

fn part_two(input: &Input) -> i64 {
    let mut program = Program::from((input, 2));
    program.run();
    program.output().unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input() -> Input {
        Input::from("1102,34915192,34915192,7,4,7,99,0")
    }

    #[test]
    fn test_part_one() {
        assert_eq!(part_one(&input()), 1219070632396864);
    }
}
