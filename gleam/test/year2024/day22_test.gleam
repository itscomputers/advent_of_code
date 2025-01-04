import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day22

const ex1 = "1
10
100
2024"

const ex2 = "1
2
3
2024"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  ex1 |> day22.main(PartOne) |> should.equal("37327623")
}

pub fn part_two_test() {
  ex2 |> day22.main(PartTwo) |> should.equal("23")
}
