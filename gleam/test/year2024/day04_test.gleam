import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day04

const example = "MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day04.main(PartOne) |> should.equal("18")
}

pub fn part_two_test() {
  example |> day04.main(PartTwo) |> should.equal("9")
}
