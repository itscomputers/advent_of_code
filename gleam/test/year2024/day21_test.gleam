import gleeunit
import gleeunit/should

import args.{PartOne}
import year2024/day21

const example = "029A
980A
179A
456A
379A"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day21.main(PartOne) |> should.equal("126384")
}
