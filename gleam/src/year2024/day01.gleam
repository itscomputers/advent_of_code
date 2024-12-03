import gleam/int
import gleam/list

import args.{type Part, PartOne, PartTwo}
import counter
import regex
import util

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> build_lists |> distance |> int.to_string
    PartTwo -> input |> build_lists |> similarity |> int.to_string
  }
}

fn distance(lists: #(List(Int), List(Int))) -> Int {
  list.zip(
    lists.0 |> list.sort(by: int.compare),
    lists.1 |> list.sort(by: int.compare),
  )
  |> list.map(fn(tuple) { int.absolute_value(tuple.0 - tuple.1) })
  |> int.sum
}

fn similarity(lists: #(List(Int), List(Int))) -> Int {
  let #(source, target) = lists
  let target_counts = counter.from_list(target)
  source
  |> list.fold(from: 0, with: fn(acc, key) {
    acc + key * counter.get(target_counts, key)
  })
}

fn build_lists(input: String) -> #(List(Int), List(Int)) {
  input
  |> util.lines
  |> list.map(regex.int_matches)
  |> list.fold(from: #([], []), with: fn(acc, ints) {
    case ints {
      [first, second] -> #([first, ..acc.0], [second, ..acc.1])
      _ -> acc
    }
  })
}
