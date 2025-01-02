import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day20

const example = "###############
#...#...#.....#
#.#.#.#.#.###.#
#S#...#.#.#...#
#######.#.#.###
#######.#.#...#
#######.#.###.#
###..E#...#...#
###.#######.###
#...###...#...#
#.#####.#.###.#
#.#...#.#.#...#
#.#.#.#.#.#.###
#...#...#...###
###############"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example
  |> day20.race(PartOne, 9)
  |> day20.cheat_count
  |> should.equal(10)
}

pub fn part_two_test() {
  example
  |> day20.race(PartTwo, 50)
  |> day20.cheat_count
  |> should.equal(285)
}
