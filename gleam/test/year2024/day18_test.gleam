import gleeunit
import gleeunit/should

import args.{PartTwo}
import year2024/day18

const example = "5,4
4,2
4,5
3,0
2,1
6,3
2,4
1,5
0,6
3,3
2,6
5,1
1,2
5,5
2,5
6,5
1,4
0,4
6,4
1,1
6,1
1,0
0,5
1,6
2,0"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day18.part_one(12, 7) |> should.equal(22)
}

pub fn part_two_test() {
  example |> day18.part_two(12, 7) |> should.equal("6,1")
}
