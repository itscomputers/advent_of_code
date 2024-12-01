import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day01

const example = "3   4
4   3
2   5
1   3
3   9
3   3"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day01.run(PartOne) |> should.equal("11")
}

pub fn part_two_test() {
  example |> day01.run(PartTwo) |> should.equal("31")
}
