import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2023/day22

const example = "1,0,1~1,2,1
0,0,2~2,0,2
0,2,3~2,2,3
0,0,4~0,2,4
2,0,5~2,2,5
0,1,6~2,1,6
1,1,8~1,1,9"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day22.main(PartOne) |> should.equal("5")
}

pub fn part_two_test() {
  example |> day22.main(PartTwo) |> should.equal("7")
}
