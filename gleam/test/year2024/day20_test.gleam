import gleam/list
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
  [
    #(64, 1),
    #(40, 2),
    #(38, 3),
    #(36, 4),
    #(20, 5),
    #(12, 8),
    #(10, 10),
    #(8, 14),
    #(6, 16),
    #(4, 30),
    #(2, 44),
  ]
  |> list.each(fn(t) {
    let #(threshold, expected_count) = t
    example
    |> day20.race
    |> day20.count(PartOne, threshold)
    |> should.equal(expected_count)
  })
}

pub fn part_two_test() {
  [
    #(76, 3),
    #(74, 7),
    #(72, 29),
    #(70, 41),
    #(68, 55),
    #(66, 67),
    #(64, 86),
    #(62, 106),
  ]
  |> list.each(fn(t) {
    let #(threshold, expected_count) = t
    example
    |> day20.race
    |> day20.count(PartTwo, threshold)
    |> should.equal(expected_count)
  })
}
