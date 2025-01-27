import gleeunit
import gleeunit/should

import range.{Range}
import year2023/day24

const example = "19, 13, 30 @ -2,  1, -2
18, 19, 22 @ -1, -1, -2
20, 25, 34 @ -2, -2, -4
12, 31, 28 @ -1, -2, -1
20, 19, 15 @  1, -5, -3"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example
  |> day24.hailstones
  |> day24.intersection_count(Range(7, 27))
  |> should.equal(2)
}
