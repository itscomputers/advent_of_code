import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day07

const example = "190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day07.main(PartOne) |> should.equal("3749")
}

pub fn part_two_test() {
  example |> day07.main(PartTwo) |> should.equal("11387")
}
