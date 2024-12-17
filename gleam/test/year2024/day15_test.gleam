import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day15

const ex1 = "##########
#..O..O.O#
#......O.#
#.OO..O.O#
#..O@..O.#
#O#..O...#
#O..O..O.#
#.OO.O.OO#
#....O...#
##########

<vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
<<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
>^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
<><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^"

const ex2 = "########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<"

const ex3 = "#####
#...#
#.O@#
#OO.#
#O#.#
#...#
#####

<^<<v"

const ex4 = "#####
#...#
#.O@#
#OO.#
##O.#
#...#
#####

<^<<v"

const ex5 = "######
#....#
#..#.#
#....#
#.O..#
#.OO@#
#.O..#
#....#
######

<vv<<^^^"

const ex6 = "#######
#.....#
#.OO@.#
#.....#
#######

<<"

const ex7 = "#######
#.....#
#.O#..#
#..O@.#
#.....#
#######

<v<<^"

const ex8 = "#######
#.....#
#.#O..#
#..O@.#
#.....#
#######

<v<^"

const ex9 = "######
#....#
#.O..#
#.OO@#
#.O..#
#....#
######

<vv<<^"

const ex10 = "#######
#.....#
#.O.O@#
#..O..#
#..O..#
#.....#
#######

<v<<>vv<^^"

const ex11 = "########
#......#
#OO....#
#.O....#
#.O....#
##O....#
#O..O@.#
#......#
########

<^^<<>^^^<v"

const ex12 = "########
#..O.O.#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

<^^>>>vv<v>>v<<"

const ex13 = "#######
#...#.#
#.....#
#..OO@#
#..O..#
#.....#
#######

<vv<<^^<<^^"

const ex14 = "#######
#...#.#
#.....#
#.....#
#.....#
#.....#
#.OOO@#
#.OOO.#
#..O..#
#.....#
#.....#
#######

v<vv<<^^^^^"

const ex15 = "#######
#.....#
#..O..#
#@O.O.#
#.#.O.#
#.....#
#######

>>^^>>>>>>vv<^^<<v"

const ex16 = "########
#......#
#..O...#
#.O....#
#..O...#
#@O....#
#......#
########

>>^<^>^^>>>>v<<^<<<vvvvv>>"

const ex17 = "########
#......#
#..O...#
#.O....#
#..O...#
#@O....#
#......#
########

>>^<^>^^>>>>v<<^<<<vvvvv>>^"

const ex18 = "########
#......#
##@.O..#
#...O..#
#.#.O..#
#...O..#
#......#
########

>>>vv><^^^>vv"

const ex19 = "########
#......#
#OO....#
#.O....#
#.O....#
##O....#
#O..O@.#
#......#
########

<^^<<>^^^<v"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_1_test() {
  ex1 |> day15.main(PartOne) |> should.equal("10092")
}

pub fn part_one_2_test() {
  ex2 |> day15.main(PartOne) |> should.equal("2028")
}

pub fn part_two_1_test() {
  ex1 |> day15.main(PartTwo) |> should.equal("9021")
}

pub fn part_two_3_test() {
  ex3 |> day15.main(PartTwo) |> should.equal("1211")
}

pub fn part_two_4_test() {
  ex4 |> day15.main(PartTwo) |> should.equal("1213")
}

pub fn part_two_5_test() {
  ex5 |> day15.main(PartTwo) |> should.equal("1216")
}

pub fn part_two_6_test() {
  ex6 |> day15.main(PartTwo) |> should.equal("406")
}

pub fn part_two_7_test() {
  ex7 |> day15.main(PartTwo) |> should.equal("509")
}

pub fn part_two_8_test() {
  ex8 |> day15.main(PartTwo) |> should.equal("511")
}

pub fn part_two_9_test() {
  ex9 |> day15.main(PartTwo) |> should.equal("816")
}

pub fn part_two_10_test() {
  ex10 |> day15.main(PartTwo) |> should.equal("822")
}

pub fn part_two_11_test() {
  ex11 |> day15.main(PartTwo) |> should.equal("2827")
}

pub fn part_two_12_test() {
  ex12 |> day15.main(PartTwo) |> should.equal("1751")
}

pub fn part_two_13_test() {
  ex13 |> day15.main(PartTwo) |> should.equal("618")
}

pub fn part_two_14_test() {
  ex14 |> day15.main(PartTwo) |> should.equal("2339")
}

pub fn part_two_15_test() {
  ex15 |> day15.main(PartTwo) |> should.equal("1226")
}

pub fn part_two_16_test() {
  ex16 |> day15.main(PartTwo) |> should.equal("1420")
}

pub fn part_two_17_test() {
  ex17 |> day15.main(PartTwo) |> should.equal("1020")
}

pub fn part_two_18_test() {
  ex18 |> day15.main(PartTwo) |> should.equal("1833")
}

pub fn part_two_19_test() {
  ex19 |> day15.main(PartTwo) |> should.equal("2827")
}
