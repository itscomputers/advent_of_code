import args.{type Part, PartOne, PartTwo}
import gleam/function
import gleam/int
import gleam/list
import gleam/string

import counter.{type Counter}
import regex
import util

pub fn main(input: String, part: Part) -> String {
  let stones = input |> stones |> blink(times: 25)
  case part {
    PartOne -> stones |> count |> int.to_string
    PartTwo -> stones |> blink(times: 50) |> count |> int.to_string
  }
}

pub fn stones(input: String) -> Counter(Int) {
  input |> regex.int_matches |> counter.from_list
}

pub fn count(stones: Counter(Int)) -> Int {
  stones |> counter.fold(from: 0, with: fn(acc, _, count) { acc + count })
}

pub fn blink(stones: Counter(Int), times count: Int) -> Counter(Int) {
  case count {
    0 -> stones
    _ -> stones |> blink_once |> blink(count - 1)
  }
}

fn blink_once(stones: Counter(Int)) -> Counter(Int) {
  stones
  |> counter.fold(from: counter.new(), with: fn(acc, stone, count) {
    stone
    |> change
    |> list.fold(from: counter.new(), with: fn(sub, new_stone) {
      sub |> counter.increment(new_stone, by: count)
    })
    |> counter.combine(acc)
  })
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
