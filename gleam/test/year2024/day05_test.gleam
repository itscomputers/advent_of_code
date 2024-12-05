import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day05

const example = "47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day05.main(PartOne) |> should.equal("143")
}

pub fn part_two_test() {
  example |> day05.main(PartTwo) |> should.equal("123")
}
