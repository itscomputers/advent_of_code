import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day10

const example = "89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day10.main(PartOne) |> should.equal("36")
}

pub fn part_two_test() {
  example |> day10.main(PartTwo) |> should.equal("81")
}
