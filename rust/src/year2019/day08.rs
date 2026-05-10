use crate::io::{Input, Solution};

pub fn solve(part: &str, input: &Input) -> Solution {
    Solution::build(part, input, &part_one, &part_two)
}

fn part_one(input: &Input) -> usize {
    validate(input, 25, 6)
}

fn part_two(input: &Input) -> usize {
    decode(input, 25, 6).show()
}

fn validate(input: &Input, width: usize, height: usize) -> usize {
    let layers = Layer::all(input, width, height);
    match layers
        .iter()
        .min_by(|l1, l2| l1.count('0').cmp(&l2.count('0')))
    {
        Some(layer) => layer.count('1') * layer.count('2'),
        None => 0,
    }
}

fn decode(input: &Input, width: usize, height: usize) -> Layer {
    let layers = Layer::all(input, width, height);
    layers
        .iter()
        .fold(Layer::transparent(width, height), |layer, lower| {
            layer.combine(lower)
        })
}

#[derive(Debug, Eq, PartialEq)]
struct Layer {
    digits: String,
    width: usize,
    height: usize,
}

impl Layer {
    fn all(input: &Input, width: usize, height: usize) -> Vec<Self> {
        let size = width * height;
        let mut layers = Vec::new();
        for i in 0..(input.data.len() / size) {
            let lower = i * size;
            let upper = lower + size;
            let digits = input.data[lower..upper].to_string();
            layers.push(Self {
                digits,
                width,
                height,
            });
        }
        layers
    }

    fn count(&self, digit: char) -> usize {
        self.digits
            .chars()
            .fold(0, |acc, ch| if ch == digit { acc + 1 } else { acc })
    }

    fn combine(&self, lower: &Layer) -> Self {
        let width = self.width;
        let height = self.height;
        let digits = (0..self.digits.len())
            .map(|i| {
                if self.char_at(i) == '2' {
                    lower.char_at(i)
                } else {
                    self.char_at(i)
                }
            })
            .collect::<String>();
        Self {
            digits,
            width,
            height,
        }
    }

    fn char_at(&self, index: usize) -> char {
        self.digits.as_bytes()[index] as char
    }

    fn show(&self) -> usize {
        for i in 0..(self.digits.len() / self.width) {
            let lower = i * self.width;
            let upper = lower + self.width;
            let display = self.digits[lower..upper]
                .chars()
                .map(|ch| if ch == '1' { '#' } else { ' ' })
                .collect::<String>();
            println!("{}", display);
        }
        1
    }

    fn transparent(width: usize, height: usize) -> Self {
        let size = width * height;
        let digits = (0..size).map(|_| '2').collect::<String>();
        Self {
            digits,
            width,
            height,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn input1() -> Input {
        Input::from("123456789012")
    }

    fn input2() -> Input {
        Input::from("0222112222120000")
    }

    #[test]
    fn test_part_one() {
        assert_eq!(validate(&input1(), 3, 2), 1);
    }

    #[test]
    fn test_part_two() {
        assert_eq!(
            decode(&input2(), 2, 2),
            Layer {
                digits: "0110".to_string(),
                width: 2,
                height: 2
            }
        );
    }
}
