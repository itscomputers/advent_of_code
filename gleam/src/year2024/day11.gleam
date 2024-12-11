import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/string

import regex
import util

pub fn main(input: String, part: Part) -> String {
  let stones = input |> stones |> util.println("start") |> blink(times: 25)
  case part {
    PartOne -> stones |> list.length |> int.to_string
    PartTwo -> stones |> blink(times: 0) |> list.length |> int.to_string
  }
}

fn stones(input: String) -> List(Int) {
  input |> regex.int_matches
}

fn blink(stones: List(Int), times count: Int) -> List(Int) {
  case count {
    0 -> stones
    _ -> blink(stones |> blink_once, count - 1)
  }
}

fn blink_once(stones: List(Int)) -> List(Int) {
  stones |> util.println("blink") |> list.map(change) |> list.flatten
}

fn change(stone: Int) -> List(Int) {
  case stone, { stone |> int.to_string |> string.length } % 2 {
    0, _ -> [1]
    _, 0 -> stone |> split
    _, _ -> [stone * 2024]
  }
}

fn split(stone: Int) -> List(Int) {
  let length = stone |> int.to_string |> string.length
  let divisor = exp(length / 2)
  [stone / divisor, stone % divisor]
}

fn exp(exponent: Int) -> Int {
  case exponent {
    0 -> 1
    e if e % 2 == 0 -> exp(e / 2) |> square
    _ -> exp(exponent - 1) * 10
  }
}

fn square(number: Int) -> Int {
  number * number
}
