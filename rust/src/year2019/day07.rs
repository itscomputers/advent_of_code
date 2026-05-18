use itertools::Itertools;

use crate::{
    io::{Input, Solution},
    year2019::computer::{Computer, Program},
};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> i64 {
    [0, 1, 2, 3, 4]
        .iter()
        .permutations(5)
        .map(|phases| run_series(input, phases))
        .max()
        .unwrap()
}

fn part_two(input: &Input) -> i64 {
    [5, 6, 7, 8, 9]
        .iter()
        .permutations(5)
        .map(|phases| Series::new(input, &phases.to_vec()).thruster())
        .max()
        .unwrap()
}

fn run(input: &Input, phase: &i64, initial: i64) -> i64 {
    let mut program = Program::from((input, vec![*phase, initial]));
    program.run();
    program.output().unwrap()
}

fn run_series(input: &Input, phases: Vec<&i64>) -> i64 {
    let out0 = run(input, phases[0], 0);
    let out1 = run(input, phases[1], out0);
    let out2 = run(input, phases[2], out1);
    let out3 = run(input, phases[3], out2);
    run(input, phases[4], out3)
}

struct Series {
    computers: Vec<Computer>,
}

impl Series {
    fn new(input: &Input, phases: &[&i64]) -> Self {
        let computers = phases
            .iter()
            .map(|phase| Computer::new(Program::from((input, **phase))))
            .collect::<Vec<_>>();
        Self { computers }
    }

    fn thruster(&mut self) -> i64 {
        let mut input = 0;
        for i in (0..5).cycle() {
            if self.computers[i].terminated() {
                return *self.computers[4].output();
            }
            input = self.computers[i].io_loop(input);
        }
        0
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input1() -> Input {
        Input::from("3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0")
    }

    fn input2() -> Input {
        Input::from(
            "3,23,3,24,1002,24,10,24,1002,23,-1,23,\
            101,5,23,23,1,24,23,23,4,23,99,0,0",
        )
    }

    fn input3() -> Input {
        Input::from(
            "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,\
            1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0",
        )
    }

    fn input4() -> Input {
        Input::from(
            "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,\
            27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5",
        )
    }

    fn input5() -> Input {
        Input::from(
            "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,\
            -5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,\
            53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10",
        )
    }

    #[test]
    fn test_part_one_1() {
        assert_eq!(part_one(&input1()), 43210);
    }

    #[test]
    fn test_part_one_2() {
        assert_eq!(part_one(&input2()), 54321);
    }

    #[test]
    fn test_part_one_3() {
        assert_eq!(part_one(&input3()), 65210);
    }

    #[test]
    fn test_part_two_1() {
        assert_eq!(part_two(&input4()), 139629729);
    }

    #[test]
    fn test_part_two_2() {
        assert_eq!(part_two(&input5()), 18216);
    }
}
