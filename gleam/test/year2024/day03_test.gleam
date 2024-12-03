import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day03

const ex1 = "xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))"

const ex2 = "xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  ex1 |> day03.main(PartOne) |> should.equal("161")
}

pub fn part_two_test() {
  ex2 |> day03.main(PartTwo) |> should.equal("48")
}
