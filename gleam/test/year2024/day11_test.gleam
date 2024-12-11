import gleeunit
import gleeunit/should

import args.{PartOne}
import year2024/day11

const example = "125 17"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day11.main(PartOne) |> should.equal("55313")
}
