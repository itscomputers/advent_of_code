import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}

import args.{type Part, PartOne, PartTwo}
import regex

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> sum |> int.to_string
    PartTwo -> input |> blocks |> list.map(sum) |> int.sum |> int.to_string
  }
}

fn sum(input: String) -> Int {
  input |> matches |> list.map(multiply) |> int.sum
}

fn matches(input: String) -> List(Match) {
  input |> regex.matches("mul\\((\\d\\d?\\d?),(\\d\\d?\\d?)\\)")
}

fn multiply(match: Match) -> Int {
  case
    match.submatches
    |> list.map(fn(opt) {
      opt
      |> option.map(int.parse)
      |> option.map(option.from_result)
      |> option.flatten
    })
  {
    [Some(a), Some(b)] -> a * b
    _ -> 0
  }
}

fn blocks(input: String) -> List(String) {
  input
  |> regex.split("do\\(\\)")
  |> list.map(fn(block) {
    case block |> regex.split("don't\\(\\)") {
      [do, ..] -> do
      _ -> block
    }
  })
}
