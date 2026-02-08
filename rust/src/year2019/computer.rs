use std::collections::VecDeque;
use std::str::FromStr;
use std::{io, io::Write};

use crate::parser;

pub struct Computer {
    program: Vec<i32>,
    index: usize,
    inputs: VecDeque<i32>,
    output: Option<i32>,
    terminated: bool,
    debug: bool,
}

#[derive(Debug, PartialEq, Eq)]
pub struct ProgramParseError;

impl FromStr for Computer {
    type Err = ProgramParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let program = parser::int_vec(s, ",");
        Ok(Computer::new(program))
    }
}

impl Computer {
    pub fn new(program: Vec<i32>) -> Computer {
        Computer {
            program,
            index: 0,
            inputs: VecDeque::new(),
            output: None,
            terminated: false,
            debug: false,
        }
    }

    pub fn automated(program: Vec<i32>, inputs: Vec<i32>) -> Computer {
        Computer {
            program,
            index: 0,
            inputs: VecDeque::from(inputs),
            output: None,
            terminated: false,
            debug: false,
        }
    }

    pub fn debug(program: Vec<i32>, inputs: Vec<i32>) -> Computer {
        Computer {
            program,
            index: 0,
            inputs: VecDeque::from(inputs),
            output: None,
            terminated: false,
            debug: true,
        }
    }

    pub fn run(&mut self) {
        while !self.terminated {
            self.next();
        }
    }

    pub fn next(&mut self) {
        if !self.terminated {
            match self.opcode() {
                1 | 2 | 7 | 8 => self.binop(),
                3 => self.stdin(),
                4 => self.stdout(),
                5 => self.jump_if(true),
                6 => self.jump_if(false),
                99 => self.halt(),
                _ => panic!("unsupported operation"),
            }
        }
    }

    pub fn program(&self) -> &Vec<i32> {
        &self.program
    }

    pub fn output(&self) -> Option<i32> {
        self.output
    }

    fn opcode(&self) -> i32 {
        self.program[self.index] % 100
    }

    fn modes(&self) -> (Mode, Mode, Mode) {
        let value = self.program[self.index];
        (
            Mode::new(&value, 100),
            Mode::new(&value, 1000),
            Mode::new(&value, 10000),
        )
    }

    fn parameter(&self, index: usize, mode: Mode) -> i32 {
        match mode {
            Mode::Position => self.value(self.program[index]),
            Mode::Immediate => self.program[index],
        }
    }

    fn value(&self, index: i32) -> i32 {
        self.program[self.address(index)]
    }

    fn address(&self, index: i32) -> usize {
        match usize::try_from(index) {
            Ok(index) => index,
            Err(_) => panic!("invalid program"),
        }
    }

    fn binop(&mut self) {
        let (m1, m2, _) = self.modes();
        let a = self.parameter(self.index + 1, m1);
        let b = self.parameter(self.index + 2, m2);
        let addr = self.address(self.program[self.index + 3]);
        let value = match self.opcode() {
            1 => a + b,
            2 => a * b,
            7 => (a < b) as i32,
            8 => (a == b) as i32,
            _ => panic!("unsupported operation"),
        };
        self.program[addr] = value;
        self.index += 4;
        self.next()
    }

    fn halt(&mut self) {
        self.terminated = true;
    }

    fn stdin(&mut self) {
        match self.inputs.pop_front() {
            Some(input) => self.automated_stdin(input),
            None => self.io_stdin(),
        }
    }

    fn stdout(&mut self) {
        let (m, _, _) = self.modes();
        let value = self.parameter(self.index + 1, m);
        self.output = Some(value);
        self.index += 2;
        self.next()
    }

    fn jump_if(&mut self, condition: bool) {
        let (m1, m2, _) = self.modes();
        let a = self.parameter(self.index + 1, m1);
        if (a == 0) ^ condition {
            self.index = self.address(self.parameter(self.index + 2, m2));
        } else {
            self.index += 3;
        }
        self.next()
    }

    fn automated_stdin(&mut self, input: i32) {
        let addr = self.address(self.program[self.index + 1]);
        self.program[addr] = input;
        self.index += 2;
        self.next()
    }

    fn io_stdin(&mut self) {
        let mut str_input = String::new();
        print!("program requires input: ");
        io::stdout().flush().expect("error with stdout");
        match io::stdin().read_line(&mut str_input) {
            Ok(_) => match str_input.trim().parse::<i32>() {
                Ok(input) => self.automated_stdin(input),
                Err(_) => panic!("unsupported input"),
            },
            Err(_) => panic!("unsupported input"),
        }
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
enum Mode {
    Position,
    Immediate,
}

impl Mode {
    fn new(value: &i32, power: i32) -> Self {
        match (value / power) % 10 {
            0 => Mode::Position,
            1 => Mode::Immediate,
            _ => panic!("unsupported parameter mode"),
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_from_str() {
        let computer = Computer::from_str("1,9,10,3,2,3,11,0,99,30,40,50").unwrap();
        assert_eq!(
            &vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50],
            computer.program(),
        );
    }

    #[test]
    fn test_opcode_1() {
        let mut computer = Computer::new(vec![1, 0, 0, 0, 99]);
        computer.run();
        assert_eq!(&vec![2, 0, 0, 0, 99], computer.program());
    }

    #[test]
    fn test_opcodes_1_2_ex_a() {
        let mut computer = Computer::new(vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]);
        computer.run();
        assert_eq!(
            &vec![3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50],
            computer.program()
        );
    }

    #[test]
    fn test_opcodes_1_2_ex_b() {
        let mut computer = Computer::new(vec![1, 1, 1, 4, 99, 5, 6, 0, 99]);
        computer.run();
        assert_eq!(&vec![30, 1, 1, 4, 2, 5, 6, 0, 99], computer.program());
    }

    #[test]
    fn test_opcode_2_ex_a() {
        let mut computer = Computer::new(vec![2, 3, 0, 3, 99]);
        computer.run();
        assert_eq!(&vec![2, 3, 0, 6, 99], computer.program());
    }

    #[test]
    fn test_opcode_2_ex_b() {
        let mut computer = Computer::new(vec![2, 4, 4, 5, 99, 0]);
        computer.run();
        assert_eq!(&vec![2, 4, 4, 5, 99, 9801], computer.program());
    }

    #[test]
    fn test_opcode_3() {
        let mut computer = Computer::automated(vec![3, 2, 0], vec![99]);
        computer.run();
        assert_eq!(&vec![3, 2, 99], computer.program());
    }

    #[test]
    fn test_opcodes_1_2_3() {
        let mut computer = Computer::automated(vec![1, 0, 4, 4, 2, 0, 99], vec![69]);
        computer.run();
        assert_eq!(&vec![69, 0, 4, 4, 3, 0, 99], computer.program());
    }

    #[test]
    fn test_opcode_4() {
        let mut computer = Computer::new(vec![4, 3, 99, 69]);
        computer.run();
        assert_eq!(&vec![4, 3, 99, 69], computer.program());
        assert_eq!(Some(69), computer.output());
    }

    #[test]
    fn test_opcode_3_4() {
        let mut computer = Computer::automated(vec![3, 0, 4, 0, 99], vec![69]);
        computer.run();
        assert_eq!(&vec![69, 0, 4, 0, 99], computer.program());
        assert_eq!(Some(69), computer.output());
    }

    #[test]
    fn test_opcode_2_immediate() {
        let mut computer = Computer::new(vec![1002, 4, 3, 4, 33]);
        computer.run();
        assert_eq!(&vec![1002, 4, 3, 4, 99], computer.program());
    }

    #[test]
    fn test_opcode_1_immediate() {
        let mut computer = Computer::new(vec![1101, 100, -1, 4, 0]);
        computer.run();
        assert_eq!(&vec![1101, 100, -1, 4, 99], computer.program());
    }

    #[test]
    fn test_opcode_5_ex_a() {
        let mut computer = Computer::new(vec![5, 9, 8, 1, 2, 2, 2, 99, 7, -4]);
        computer.run();
        assert_eq!(&vec![5, 9, 8, 1, 2, 2, 2, 99, 7, -4], computer.program());
    }

    #[test]
    fn test_opcode_5_ex_b() {
        let mut computer = Computer::new(vec![5, 9, 8, 1, 2, 2, 2, 99, 7, 0]);
        computer.run();
        assert_eq!(&vec![5, 9, 16, 1, 2, 2, 2, 99, 7, 0], computer.program());
    }

    #[test]
    fn test_opcode_5_immediate_a() {
        let mut computer = Computer::new(vec![105, -4, 8, 1, 2, 2, 2, 99, 7]);
        computer.run();
        assert_eq!(&vec![105, -4, 8, 1, 2, 2, 2, 99, 7], computer.program());
    }

    #[test]
    fn test_opcode_5_immediate_b() {
        let mut computer = Computer::new(vec![105, 0, 8, 1, 2, 2, 2, 99, 7]);
        computer.run();
        assert_eq!(&vec![105, 0, 16, 1, 2, 2, 2, 99, 7], computer.program());
    }

    #[test]
    fn test_opcode_5_immediate_c() {
        let mut computer = Computer::new(vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, -4]);
        computer.run();
        assert_eq!(&vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, -4], computer.program());
    }

    #[test]
    fn test_opcode_5_immediate_d() {
        let mut computer = Computer::new(vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, 0]);
        computer.run();
        assert_eq!(&vec![1005, 9, 14, 1, 2, 2, 2, 99, 2, 0], computer.program());
    }

    #[test]
    fn test_opcode_6_ex_a() {
        let mut computer = Computer::new(vec![6, 9, 8, 1, 2, 2, 2, 99, 7, 0]);
        computer.run();
        assert_eq!(&vec![6, 9, 8, 1, 2, 2, 2, 99, 7, 0], computer.program());
    }

    #[test]
    fn test_opcode_6_ex_b() {
        let mut computer = Computer::new(vec![6, 9, 8, 1, 2, 2, 2, 99, 7, -4]);
        computer.run();
        assert_eq!(&vec![6, 9, 16, 1, 2, 2, 2, 99, 7, -4], computer.program());
    }

    #[test]
    fn test_opcode_7_ex_a() {
        let mut computer = Computer::new(vec![7, 6, 5, 0, 99, 43, 41]);
        computer.run();
        assert_eq!(&vec![1, 6, 5, 0, 99, 43, 41], computer.program());
    }

    #[test]
    fn test_opcode_7_ex_b() {
        let mut computer = Computer::new(vec![7, 6, 5, 0, 99, 41, 43]);
        computer.run();
        assert_eq!(&vec![0, 6, 5, 0, 99, 41, 43], computer.program());
    }

    #[test]
    fn test_opcode_7_ex_c() {
        let mut computer = Computer::new(vec![7, 6, 5, 0, 99, 41, 41]);
        computer.run();
        assert_eq!(&vec![0, 6, 5, 0, 99, 41, 41], computer.program());
    }

    #[test]
    fn test_opcode_8_ex_a() {
        let mut computer = Computer::new(vec![8, 6, 5, 0, 99, 41, 41]);
        computer.run();
        assert_eq!(&vec![1, 6, 5, 0, 99, 41, 41], computer.program());
    }

    #[test]
    fn test_opcode_8_ex_b() {
        let mut computer = Computer::new(vec![8, 6, 5, 0, 99, 41, 43]);
        computer.run();
        assert_eq!(&vec![0, 6, 5, 0, 99, 41, 43], computer.program());
    }

    #[test]
    fn test_position_mode_ex_a() {
        let mut computer = Computer::automated(vec![3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], vec![10]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_position_mode_ex_b() {
        let mut computer = Computer::automated(vec![3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], vec![8]);
        computer.run();
        assert_eq!(Some(1), computer.output());
    }

    #[test]
    fn test_position_mode_ex_c() {
        let mut computer = Computer::automated(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![7]);
        computer.run();
        assert_eq!(Some(1), computer.output());
    }

    #[test]
    fn test_position_mode_ex_d() {
        let mut computer = Computer::automated(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![8]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_position_mode_ex_e() {
        let mut computer = Computer::automated(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![10]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_immediate_mode_ex_a() {
        let mut computer = Computer::automated(vec![3, 3, 1108, -1, 8, 3, 4, 3, 99], vec![10]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_immediate_mode_ex_b() {
        let mut computer = Computer::automated(vec![3, 3, 1108, -1, 8, 3, 4, 3, 99], vec![8]);
        computer.run();
        assert_eq!(Some(1), computer.output());
    }

    #[test]
    fn test_immediate_mode_ex_c() {
        let mut computer = Computer::automated(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![7]);
        computer.run();
        assert_eq!(Some(1), computer.output());
    }

    #[test]
    fn test_immediate_mode_ex_d() {
        let mut computer = Computer::automated(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![8]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_immediate_mode_ex_e() {
        let mut computer = Computer::automated(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![10]);
        computer.run();
        assert_eq!(Some(0), computer.output());
    }

    #[test]
    fn test_long_program_ex_a() {
        let mut computer = Computer::automated(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![5],
        );
        computer.run();
        assert_eq!(Some(999), computer.output());
    }

    #[test]
    fn test_long_program_ex_b() {
        let mut computer = Computer::automated(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![8],
        );
        computer.run();
        assert_eq!(Some(1000), computer.output());
    }

    #[test]
    fn test_long_program_ex_c() {
        let mut computer = Computer::automated(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![10],
        );
        computer.run();
        assert_eq!(Some(1001), computer.output());
    }
}
