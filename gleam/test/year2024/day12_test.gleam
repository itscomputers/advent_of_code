import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day12

const ex1 = "AAAA
BBCD
BBCC
EEEC"

const ex2 = "OOOOO
OXOXO
OOOOO
OXOXO
OOOOO"

const ex3 = "RRRRIICCFF
RRRRIICCCF
VVRRRCCFFF
VVRCCCJFFF
VVVVCJJCFE
VVIVCCJJEE
VVIIICJJEE
MIIIIIJJEE
MIIISIJEEE
MMMISSJEEE"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_ex1_test() {
  ex1 |> day12.main(PartOne) |> should.equal("140")
}

pub fn part_one_ex2_test() {
  ex2 |> day12.main(PartOne) |> should.equal("772")
}

pub fn part_one_ex3_test() {
  ex3 |> day12.main(PartOne) |> should.equal("1930")
}

pub fn part_two_ex1_test() {
  ex1 |> day12.main(PartTwo) |> should.equal("80")
}

pub fn part_two_ex2_test() {
  ex2 |> day12.main(PartTwo) |> should.equal("436")
}

pub fn part_two_ex3_test() {
  ex3 |> day12.main(PartTwo) |> should.equal("1206")
}
