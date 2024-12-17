import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day16

const ex1 = "###############
#.......#....E#
#.#.###.#.###.#
#.....#.#...#.#
#.###.#####.#.#
#.#.#.......#.#
#.#.#####.###.#
#...........#.#
###.#.#####.#.#
#...#.....#.#.#
#.#.#.###.#.#.#
#.....#...#.#.#
#.###.#.#.#.#.#
#S..#.....#...#
###############"

const ex2 = "#################
#...#...#...#..E#
#.#.#.#.#.#.#.#.#
#.#.#.#...#...#.#
#.#.#.#.###.#.#.#
#...#.#.#.....#.#
#.#.#.#.#.#####.#
#.#...#.#.#.....#
#.#.#####.#.###.#
#.#.#.......#...#
#.#.###.#####.###
#.#.#...#.....#.#
#.#.#.#####.###.#
#.#.#.........#.#
#.#.#.#########.#
#S#.............#
#################"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_1_test() {
  ex1 |> day16.main(PartOne) |> should.equal("7036")
}

pub fn part_one_2_test() {
  ex2 |> day16.main(PartOne) |> should.equal("11048")
}

pub fn part_two_1_test() {
  ex1 |> day16.main(PartTwo) |> should.equal("45")
}

pub fn part_two_2_test() {
  ex2 |> day16.main(PartTwo) |> should.equal("64")
}
