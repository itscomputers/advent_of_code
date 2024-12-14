import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import point.{Point}
import util
import year2024/day14

const example = "p=0,4 v=3,-3
p=6,3 v=-1,-3
p=10,3 v=-1,2
p=2,0 v=2,-1
p=0,0 v=1,3
p=3,0 v=-2,-2
p=7,6 v=-1,-3
p=3,0 v=-1,-2
p=9,3 v=2,3
p=7,3 v=-1,2
p=2,4 v=2,-3
p=9,5 v=-3,-3"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example
  |> day14.safety_factor(Point(11, 7))
  |> should.equal(12)
}
