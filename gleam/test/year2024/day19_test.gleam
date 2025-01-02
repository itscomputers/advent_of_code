import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day19

const example = "r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day19.main(PartOne) |> should.equal("6")
}

pub fn part_two_test() {
  example |> day19.main(PartTwo) |> should.equal("16")
}
