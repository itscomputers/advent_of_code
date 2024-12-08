import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day06

const example = "....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day06.main(PartOne) |> should.equal("41")
}

pub fn part_two_test() {
  example |> day06.main(PartTwo) |> should.equal("6")
}
