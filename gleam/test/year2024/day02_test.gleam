import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day02

const example = "7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day02.main(PartOne) |> should.equal("2")
}

pub fn part_two_test() {
  example |> day02.main(PartTwo) |> should.equal("4")
}
