use std::str::FromStr;

pub struct Computer {
    program: Vec<usize>,
    index: usize,
}

#[derive(Debug, PartialEq, Eq)]
pub struct ProgramParseError;

impl FromStr for Computer {
    type Err = ProgramParseError;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        let program = s
            .split(",")
            .map(|x| usize::from_str(x).unwrap())
            .collect::<Vec<usize>>();
        Ok(Computer::new(program))
    }
}

impl Computer {
    pub fn new(program: Vec<usize>) -> Computer {
        Computer { program, index: 0 }
    }

    pub fn program(&self) -> &Vec<usize> {
        &self.program
    }

    fn opcode(&self) -> usize {
        self.program[self.index]
    }

    fn value(&self, index: usize) -> usize {
        self.program[self.program[index]]
    }

    pub fn run(self) -> Computer {
        match self.opcode() {
            1 | 2 => self.binop(),
            99 => self,
            _ => panic!("unsupported operation"),
        }
    }

    fn binop(mut self) -> Computer {
        let a = self.value(self.index + 1);
        let b = self.value(self.index + 2);
        let loc = self.program[self.index + 3];
        let value = match self.opcode() {
            1 => a + b,
            2 => a * b,
            _ => panic!("unsupported operation"),
        };
        self.program[loc] = value;
        self.index += 4;
        self.run()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_from_str() {
        let computer = Computer::from_str("1,9,10,3,2,3,11,0,99,30,40,50").unwrap();
        assert_eq!(
            computer.program,
            vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
        );
    }

    #[test]
    fn test_opcode_1() {
        let computer = Computer::new(vec![1, 0, 0, 0, 99]);
        assert_eq!(&vec![2, 0, 0, 0, 99], computer.run().program());
    }

    #[test]
    fn test_opcodes_1_2_a() {
        let computer = Computer::new(vec![1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]);
        assert_eq!(
            &vec![3500, 9, 10, 70, 2, 3, 11, 0, 99, 30, 40, 50],
            computer.run().program()
        );
    }

    #[test]
    fn test_opcodes_1_2_b() {
        let computer = Computer::new(vec![1, 1, 1, 4, 99, 5, 6, 0, 99]);
        assert_eq!(&vec![30, 1, 1, 4, 2, 5, 6, 0, 99], computer.run().program());
    }

    #[test]
    fn test_opcode_2_a() {
        let computer = Computer::new(vec![2, 3, 0, 3, 99]);
        assert_eq!(&vec![2, 3, 0, 6, 99], computer.run().program());
    }

    #[test]
    fn test_opcode_2_b() {
        let computer = Computer::new(vec![2, 4, 4, 5, 99, 0]);
        assert_eq!(&vec![2, 4, 4, 5, 99, 9801], computer.run().program());
    }
}
