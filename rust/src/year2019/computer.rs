use std::collections::{HashMap, VecDeque};
use std::{io, io::Write};

use crate::io::Input;

pub struct Computer {
    computer: Program,
    outputs: Vec<i64>,
}

impl Computer {
    pub fn new(computer: Program) -> Self {
        Self {
            computer,
            outputs: Vec::new(),
        }
    }

    pub fn io_loop(&mut self, input: i64) -> i64 {
        self.computer.inputs.push_back(input);
        self.next_io();
        self.interact();
        *self.output()
    }

    pub fn outputs(&self) -> &Vec<i64> {
        &self.outputs
    }

    pub fn output(&self) -> &i64 {
        if let Some(output) = self.outputs.last() {
            output
        } else {
            panic!("expected at least one output")
        }
    }

    pub fn terminated(&self) -> bool {
        self.computer.terminated
    }

    fn next_io(&mut self) {
        while !self.computer.interactable() {
            self.computer.next();
        }
    }

    fn interact(&mut self) {
        if self.computer.requires_input() {
            let mut str_input = String::new();
            print!("program requires input: ");
            io::stdout().flush().expect("error with stdout");
            match io::stdin().read_line(&mut str_input) {
                Ok(_) => match str_input.trim().parse::<i64>() {
                    Ok(input) => self.computer.inputs.push_back(input),
                    Err(_) => panic!("unsupported input"),
                },
                Err(_) => panic!("unsupported input"),
            }
        }
        if self.computer.supplies_output() {
            self.computer.next();
            self.outputs.push(self.computer.output().unwrap());
            self.next_io();
        }
    }
}

pub struct Program {
    data: Vec<i64>,
    overflow: HashMap<usize, i64>,
    index: i64,
    base: i64,
    inputs: VecDeque<i64>,
    output: Option<i64>,
    terminated: bool,
}

impl Program {
    pub fn new(program: Vec<i64>) -> Program {
        Program {
            data: program,
            overflow: HashMap::new(),
            index: 0,
            base: 0,
            inputs: VecDeque::new(),
            output: None,
            terminated: false,
        }
    }

    pub fn with_inputs(program: Vec<i64>, inputs: Vec<i64>) -> Program {
        let mut computer = Program::new(program);
        computer.inputs = VecDeque::from(inputs);
        computer
    }

    pub fn run(&mut self) {
        while !self.terminated {
            self.next();
        }
    }

    fn next(&mut self) {
        if !self.terminated {
            match self.opcode() {
                1 | 2 | 7 | 8 => self.binop(),
                3 => self.stdin(),
                4 => self.stdout(),
                5 => self.jump_if(true),
                6 => self.jump_if(false),
                9 => self.relative_offset(),
                99 => self.halt(),
                _ => panic!("unsupported operation"),
            }
        }
    }

    pub fn get(&self, index: i64) -> i64 {
        let addr = as_usize(index);
        if addr < self.data.len() {
            self.data[addr]
        } else {
            *self.overflow.get(&addr).unwrap_or(&0)
        }
    }

    fn set(&mut self, index: i64, value: i64) {
        let addr = as_usize(index);
        if addr < self.data.len() {
            self.data[addr] = value;
        } else {
            self.overflow.insert(addr, value);
        }
    }

    pub fn output(&self) -> Option<i64> {
        self.output
    }

    fn requires_input(&self) -> bool {
        self.opcode() == 3 && self.inputs.is_empty()
    }

    fn supplies_output(&self) -> bool {
        self.opcode() == 4
    }

    fn interactable(&self) -> bool {
        self.terminated || self.requires_input() || self.supplies_output()
    }

    fn opcode(&self) -> i64 {
        self.get(self.index) % 100
    }

    fn mode(&self, offset: i64) -> Mode {
        Mode::new(&self.get(self.index), offset)
    }

    /// input parameter for opcode
    fn param(&self, offset: i64) -> i64 {
        let value = self.get(self.index + offset);
        match self.mode(offset) {
            Mode::Immediate => value,
            Mode::Position => self.get(value),
            Mode::Relative => self.get(self.base + value),
        }
    }

    /// write address for opcode
    fn addr(&self, offset: i64) -> i64 {
        let value = self.get(self.index + offset);
        match self.mode(offset) {
            Mode::Immediate => panic!("invalid mode for return address"),
            Mode::Position => value,
            Mode::Relative => self.base + value,
        }
    }

    /// handler for opcodes=1,2,7,8
    fn binop(&mut self) {
        let a = self.param(1);
        let b = self.param(2);
        let value = match self.opcode() {
            1 => a + b,
            2 => a * b,
            7 => (a < b) as i64,
            8 => (a == b) as i64,
            _ => panic!("unsupported operation"),
        };
        self.set(self.addr(3), value);
        self.index += 4;
    }

    /// handler for opcode=3
    fn stdin(&mut self) {
        match self.inputs.pop_front() {
            Some(input) => {
                self.set(self.addr(1), input);
                self.index += 2;
            }
            None => panic!("program requires input"),
        }
    }

    /// handler for opcode=4
    fn stdout(&mut self) {
        self.output = Some(self.param(1));
        self.index += 2;
    }

    /// handler for opcodes=5,6
    fn jump_if(&mut self, condition: bool) {
        if (self.param(1) == 0) ^ condition {
            self.index = self.param(2);
        } else {
            self.index += 3;
        }
    }

    /// handler for opcode=9
    fn relative_offset(&mut self) {
        self.base += self.param(1);
        self.index += 2;
    }

    /// opcode 99 handler
    fn halt(&mut self) {
        self.terminated = true;
    }
}

impl From<&Input> for Program {
    fn from(input: &Input) -> Self {
        Program::new(input.int_vec(","))
    }
}

impl From<(&Input, i64)> for Program {
    fn from(value: (&Input, i64)) -> Self {
        Program::with_inputs(value.0.int_vec(","), vec![value.1])
    }
}

impl From<(&Input, Vec<i64>)> for Program {
    fn from(value: (&Input, Vec<i64>)) -> Self {
        Program::with_inputs(value.0.int_vec(","), value.1)
    }
}

fn as_usize(index: i64) -> usize {
    match usize::try_from(index) {
        Ok(i) => i,
        Err(_) => panic!("invalid program address: {}", index),
    }
}

#[derive(Debug, Copy, Clone, PartialEq, Eq)]
enum Mode {
    Position,
    Immediate,
    Relative,
}

impl Mode {
    fn new(value: &i64, offset: i64) -> Self {
        let power = (0..offset).fold(10, |acc, _| acc * 10);
        match (value / power) % 10 {
            0 => Mode::Position,
            1 => Mode::Immediate,
            2 => Mode::Relative,
            _ => panic!("unsupported parameter mode"),
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::io::Input;

    use super::*;

    #[test]
    fn test_from_input() {
        let input = Input::from("1,9,10,3,2,3,11,0,99,30,40,50");
        let computer = Program::from(&input);
        assert_eq!(
            computer.data,
            vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50],
        );
    }

    #[test]
    fn test_opcode_1() {
        let mut computer = Program::new(vec![1, 0, 0, 0, 99]);
        computer.run();
        assert_eq!(computer.data, vec![2, 0, 0, 0, 99]);
    }

    #[test]
    fn test_opcodes_1_2_ex_a() {
        let mut computer = Program::new(vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]);
        computer.run();
        assert_eq!(
            computer.data,
            vec![3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50],
        );
    }

    #[test]
    fn test_opcodes_1_2_ex_b() {
        let mut computer = Program::new(vec![1, 1, 1, 4, 99, 5, 6, 0, 99]);
        computer.run();
        assert_eq!(computer.data, vec![30, 1, 1, 4, 2, 5, 6, 0, 99]);
    }

    #[test]
    fn test_opcode_2_ex_a() {
        let mut computer = Program::new(vec![2, 3, 0, 3, 99]);
        computer.run();
        assert_eq!(computer.data, vec![2, 3, 0, 6, 99]);
    }

    #[test]
    fn test_opcode_2_ex_b() {
        let mut computer = Program::new(vec![2, 4, 4, 5, 99, 0]);
        computer.run();
        assert_eq!(computer.data, vec![2, 4, 4, 5, 99, 9801]);
    }

    #[test]
    fn test_opcode_3() {
        let mut computer = Program::with_inputs(vec![3, 2, 0], vec![99]);
        computer.run();
        assert_eq!(computer.data, vec![3, 2, 99]);
    }

    #[test]
    fn test_opcodes_1_2_3() {
        let mut computer = Program::with_inputs(vec![1, 0, 4, 4, 2, 0, 99], vec![69]);
        computer.run();
        assert_eq!(computer.data, vec![69, 0, 4, 4, 3, 0, 99]);
    }

    #[test]
    fn test_opcode_4() {
        let mut computer = Program::new(vec![4, 3, 99, 69]);
        computer.run();
        assert_eq!(computer.data, vec![4, 3, 99, 69]);
        assert_eq!(Some(69), computer.output());
    }

    #[test]
    fn test_opcode_3_4() {
        let mut computer = Program::with_inputs(vec![3, 0, 4, 0, 99], vec![69]);
        computer.run();
        assert_eq!(computer.data, vec![69, 0, 4, 0, 99]);
        assert_eq!(Some(69), computer.output());
    }

    #[test]
    fn test_opcode_2_immediate() {
        let mut computer = Program::new(vec![1002, 4, 3, 4, 33]);
        computer.run();
        assert_eq!(computer.data, vec![1002, 4, 3, 4, 99]);
    }

    #[test]
    fn test_opcode_1_immediate() {
        let mut computer = Program::new(vec![1101, 100, -1, 4, 0]);
        computer.run();
        assert_eq!(computer.data, vec![1101, 100, -1, 4, 99]);
    }

    #[test]
    fn test_opcode_5_ex_a() {
        let mut computer = Program::new(vec![5, 9, 8, 1, 2, 2, 2, 99, 7, -4]);
        computer.run();
        assert_eq!(computer.data, vec![5, 9, 8, 1, 2, 2, 2, 99, 7, -4]);
    }

    #[test]
    fn test_opcode_5_ex_b() {
        let mut computer = Program::new(vec![5, 9, 8, 1, 2, 2, 2, 99, 7, 0]);
        computer.run();
        assert_eq!(computer.data, vec![5, 9, 16, 1, 2, 2, 2, 99, 7, 0]);
    }

    #[test]
    fn test_opcode_5_immediate_a() {
        let mut computer = Program::new(vec![105, -4, 8, 1, 2, 2, 2, 99, 7]);
        computer.run();
        assert_eq!(computer.data, vec![105, -4, 8, 1, 2, 2, 2, 99, 7]);
    }

    #[test]
    fn test_opcode_5_immediate_b() {
        let mut computer = Program::new(vec![105, 0, 8, 1, 2, 2, 2, 99, 7]);
        computer.run();
        assert_eq!(computer.data, vec![105, 0, 16, 1, 2, 2, 2, 99, 7]);
    }

    #[test]
    fn test_opcode_5_immediate_c() {
        let mut computer = Program::new(vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, -4]);
        computer.run();
        assert_eq!(computer.data, vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, -4]);
    }

    #[test]
    fn test_opcode_5_immediate_d() {
        let mut computer = Program::new(vec![1005, 9, 7, 1, 2, 2, 2, 99, 2, 0]);
        computer.run();
        assert_eq!(computer.data, vec![1005, 9, 14, 1, 2, 2, 2, 99, 2, 0]);
    }

    #[test]
    fn test_opcode_6_ex_a() {
        let mut computer = Program::new(vec![6, 9, 8, 1, 2, 2, 2, 99, 7, 0]);
        computer.run();
        assert_eq!(computer.data, vec![6, 9, 8, 1, 2, 2, 2, 99, 7, 0]);
    }

    #[test]
    fn test_opcode_6_ex_b() {
        let mut computer = Program::new(vec![6, 9, 8, 1, 2, 2, 2, 99, 7, -4]);
        computer.run();
        assert_eq!(computer.data, vec![6, 9, 16, 1, 2, 2, 2, 99, 7, -4]);
    }

    #[test]
    fn test_opcode_7_ex_a() {
        let mut computer = Program::new(vec![7, 6, 5, 0, 99, 43, 41]);
        computer.run();
        assert_eq!(computer.data, vec![1, 6, 5, 0, 99, 43, 41]);
    }

    #[test]
    fn test_opcode_7_ex_b() {
        let mut computer = Program::new(vec![7, 6, 5, 0, 99, 41, 43]);
        computer.run();
        assert_eq!(computer.data, vec![0, 6, 5, 0, 99, 41, 43]);
    }

    #[test]
    fn test_opcode_7_ex_c() {
        let mut computer = Program::new(vec![7, 6, 5, 0, 99, 41, 41]);
        computer.run();
        assert_eq!(computer.data, vec![0, 6, 5, 0, 99, 41, 41]);
    }

    #[test]
    fn test_opcode_8_ex_a() {
        let mut computer = Program::new(vec![8, 6, 5, 0, 99, 41, 41]);
        computer.run();
        assert_eq!(computer.data, vec![1, 6, 5, 0, 99, 41, 41]);
    }

    #[test]
    fn test_opcode_8_ex_b() {
        let mut computer = Program::new(vec![8, 6, 5, 0, 99, 41, 43]);
        computer.run();
        assert_eq!(computer.data, vec![0, 6, 5, 0, 99, 41, 43]);
    }

    #[test]
    fn test_position_mode_ex_a() {
        let mut computer = Program::with_inputs(vec![3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], vec![10]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_position_mode_ex_b() {
        let mut computer = Program::with_inputs(vec![3, 9, 8, 9, 10, 9, 4, 9, 99, -1, 8], vec![8]);
        computer.run();
        assert_eq!(computer.output, Some(1));
    }

    #[test]
    fn test_position_mode_ex_c() {
        let mut computer = Program::with_inputs(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![7]);
        computer.run();
        assert_eq!(computer.output, Some(1));
    }

    #[test]
    fn test_position_mode_ex_d() {
        let mut computer = Program::with_inputs(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![8]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_position_mode_ex_e() {
        let mut computer = Program::with_inputs(vec![3, 9, 7, 9, 10, 9, 4, 9, 99, -1, 8], vec![10]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_immediate_mode_ex_a() {
        let mut computer = Program::with_inputs(vec![3, 3, 1108, -1, 8, 3, 4, 3, 99], vec![10]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_immediate_mode_ex_b() {
        let mut computer = Program::with_inputs(vec![3, 3, 1108, -1, 8, 3, 4, 3, 99], vec![8]);
        computer.run();
        assert_eq!(computer.output, Some(1));
    }

    #[test]
    fn test_immediate_mode_ex_c() {
        let mut computer = Program::with_inputs(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![7]);
        computer.run();
        assert_eq!(computer.output, Some(1));
    }

    #[test]
    fn test_immediate_mode_ex_d() {
        let mut computer = Program::with_inputs(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![8]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_immediate_mode_ex_e() {
        let mut computer = Program::with_inputs(vec![3, 3, 1107, -1, 8, 3, 4, 3, 99], vec![10]);
        computer.run();
        assert_eq!(computer.output, Some(0));
    }

    #[test]
    fn test_relative_mode_ex_a() {
        let program = vec![
            109, 1, 204, -1, 1001, 100, 1, 100, 1008, 100, 16, 101, 1006, 101, 0, 99,
        ];
        let mut computer = Program::new(program.clone());
        let mut index = 0;
        while index < program.len() {
            while !computer.supplies_output() {
                computer.next();
            }
            computer.next();
            assert_eq!(computer.output, Some(program[index]));
            index += 1;
        }
        computer.run();
        assert_eq!(computer.output, Some(99));
    }

    #[test]
    fn test_relative_mode_ex_b() {
        let mut computer = Program::new(vec![1102, 34915192, 34915192, 7, 4, 7, 99, 0]);
        computer.run();
        assert_eq!(computer.output, Some(1219070632396864));
    }

    #[test]
    fn test_relative_mode_ex_c() {
        let program = vec![109, 1, 21101, 7, 3, 6, 4, 5];
        let mut computer = Program::new(program);
        computer.next();
        computer.next();
        assert_eq!(computer.data[6], 4);
        assert_eq!(computer.data[7], 7 + 3);
    }

    #[test]
    fn test_relative_mode_ex_d() {
        let program = vec![109, 1, 21102, 7, 3, 6, 4, 5];
        let mut computer = Program::new(program);
        computer.next();
        computer.next();
        assert_eq!(computer.data[6], 4);
        assert_eq!(computer.data[7], 7 * 3);
    }

    #[test]
    fn test_relative_mode_ex_e() {
        let program = vec![109, 1, 21107, 7, 3, 6, 4, 5];
        let mut computer = Program::new(program);
        computer.next();
        computer.next();
        assert_eq!(computer.data[6], 4);
        assert_eq!(computer.data[7], 0);
    }

    #[test]
    fn test_relative_mode_ex_f() {
        let program = vec![109, 1, 21108, 7, 3, 6, 4, 5];
        let mut computer = Program::new(program);
        computer.next();
        computer.next();
        assert_eq!(computer.data[6], 4);
        assert_eq!(computer.data[7], 0);
    }

    #[test]
    fn test_relative_mode_ex_g() {
        let program = vec![109, 1, 203, 6, 7, 8, 9, 5];
        let mut computer = Program::with_inputs(program, vec![69]);
        computer.next();
        computer.next();
        assert_eq!(computer.data[6], 9);
        assert_eq!(computer.data[7], 69);
    }

    #[test]
    fn test_large_integer() {
        let mut computer = Program::new(vec![104, 1125899906842624, 99]);
        computer.run();
        assert_eq!(computer.output, Some(1125899906842624));
    }

    #[test]
    fn test_long_program_ex_a() {
        let mut computer = Program::with_inputs(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![5],
        );
        computer.run();
        assert_eq!(computer.output, Some(999));
    }

    #[test]
    fn test_long_program_ex_b() {
        let mut computer = Program::with_inputs(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![8],
        );
        computer.run();
        assert_eq!(computer.output, Some(1000));
    }

    #[test]
    fn test_long_program_ex_c() {
        let mut computer = Program::with_inputs(
            vec![
                3, 21, 1008, 21, 8, 20, 1005, 20, 22, 107, 8, 21, 20, 1006, 20, 31, 1106, 0, 36,
                98, 0, 0, 1002, 21, 125, 20, 4, 20, 1105, 1, 46, 104, 999, 1105, 1, 46, 1101, 1000,
                1, 20, 4, 20, 1105, 1, 46, 98, 99,
            ],
            vec![10],
        );
        computer.run();
        assert_eq!(computer.output, Some(1001));
    }
}
