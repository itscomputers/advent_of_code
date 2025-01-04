import gleeunit
import gleeunit/should

import args.{PartOne}
import year2024/day25

const example = "#####
.####
.####
.####
.#.#.
.#...
.....

#####
##.##
.#.##
...##
...#.
...#.
.....

.....
#....
#....
#...#
#.#.#
#.###
#####

.....
.....
#.#..
###..
###.#
###.#
#####

.....
.....
.....
#....
#.#..
#.#.#
#####"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day25.main(PartOne) |> should.equal("3")
}
