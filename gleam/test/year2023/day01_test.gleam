import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2023/day01

const ex1 = "1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet"

const ex2 = "two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  ex1 |> day01.run(PartOne) |> should.equal("142")
}

pub fn part_two_test() {
  ex2 |> day01.run(PartTwo) |> should.equal("281")
}

pub fn overlapping_test() {
  "eightwo" |> day01.run(PartTwo) |> should.equal("82")
}
