import gleeunit
import gleeunit/should

import args.{PartOne}
import year2024/day17.{type IntComputer, type Register, A, B}

const ex1 = "Register A: 729
Register B: 0
Register C: 0

Program: 0,1,5,4,3,0"

// const ex2 = "Register A: 2024
// Register B: 0
// Register C: 0
//
// Program: 0,3,5,4,3,0"

const program = [2, 4, 1, 2, 7, 5, 0, 3, 1, 7, 4, 1, 5, 5, 3, 0]

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  ex1
  |> day17.main(PartOne)
  |> should.equal("4,6,3,5,6,3,5,2,1,0")
}

// pub fn part_two_test() {
//   ex2 |> day17.main(PartTwo) |> should.equal("117440")
// }

pub fn example_0_test() {
  run([2, 6], 0, 0, 9)
  |> assert_register(B, 1)
}

pub fn example_1_test() {
  run([5, 0, 5, 1, 5, 4], 10, 0, 0)
  |> assert_output([0, 1, 2])
}

pub fn example_2_test() {
  run([0, 1, 5, 4, 3, 0], 2024, 0, 0)
  |> assert_output([4, 2, 5, 6, 7, 7, 7, 7, 3, 1, 0])
  |> assert_register(A, 0)
}

pub fn example_3_test() {
  run([1, 7], 0, 29, 0)
  |> assert_register(B, 26)
}

pub fn example_4_test() {
  run([4, 0], 0, 2024, 43_690)
  |> assert_register(B, 44_354)
}

pub fn adv_1_test() {
  run([0, 3], 50, 0, 0)
  |> assert_register(A, 50 / 8)
}

pub fn adv_2_test() {
  run([0, 5], 50, 4, 0)
  |> assert_register(A, 50 / 16)
}

pub fn adv_3_test() {
  run([0, 6], 50, 0, 0)
  |> assert_register(A, 50)
}

pub fn bxl_1_test() {
  run([1, 5], 0, 99, 0)
  |> assert_register(B, 64 + 32 + 4 + 2)
}

pub fn bxl_2_test() {
  run([1, 15], 0, 39, 0)
  |> assert_register(B, 32 + 8)
}

pub fn bst_1_test() {
  run([2, 3], 13, 14, 15)
  |> assert_register(B, 3)
}

pub fn bst_2_test() {
  run([2, 4], 13, 14, 15)
  |> assert_register(B, 5)
}

pub fn bst_3_test() {
  run([2, 5], 13, 14, 15)
  |> assert_register(B, 6)
}

pub fn bst_4_test() {
  run([2, 6], 13, 14, 15)
  |> assert_register(B, 7)
}

pub fn bxc_1_test() {
  run([4, 1], 0, 12, 14)
  |> assert_register(B, 2)
}

pub fn out_1_test() {
  run([5, 0, 5, 1, 5, 2, 5, 3, 5, 4, 5, 5, 5, 6], 13, 14, 15)
  |> assert_output([0, 1, 2, 3, 5, 6, 7])
}

pub fn out_2_test() {
  run(program, 7, 0, 0)
  |> assert_output([2])
}

pub fn out_3_test() {
  run(program, 15, 0, 0)
  |> assert_output([2, 4])
}

fn run(p: List(Int), a: Int, b: Int, c: Int) -> IntComputer {
  day17.cmp(p, a, b, c) |> day17.run(day17.Normal)
}

fn assert_register(cmp: IntComputer, r: Register, e: Int) -> IntComputer {
  cmp |> day17.get(r) |> should.equal(e)
  cmp
}

fn assert_output(cmp: IntComputer, e: List(Int)) -> IntComputer {
  cmp |> day17.output |> should.equal(e)
  cmp
}
