import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day09

const example = "2333133121414131402"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day09.main(PartOne) |> should.equal("1928")
}

pub fn part_two_test() {
  example |> day09.main(PartTwo) |> should.equal("2858")
}
