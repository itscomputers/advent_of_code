import gleam/int
import gleam/list
import gleam/order

import args.{type Args, type Part, PartOne, PartTwo}
import regex
import util

pub fn main(a: Args) -> String {
  a |> args.input |> run(a.part)
}

pub fn run(input: String, part: Part) -> String {
  input
  |> reports
  |> list.filter(criteria(part))
  |> list.length
  |> int.to_string
}

fn criteria(part: Part) -> fn(List(Int)) -> Bool {
  case part {
    PartOne -> is_safe
    PartTwo -> almost_safe
  }
}

fn reports(input: String) -> List(List(Int)) {
  input
  |> util.lines
  |> list.map(regex.int_matches)
}

fn is_safe(report: List(Int)) -> Bool {
  report
  |> differences
  |> fn(diff) { is_monotonic(diff) && is_gradual(diff) }
}

fn almost_safe(report: List(Int)) -> Bool {
  list.range(0, list.length(report) - 1)
  |> list.any(fn(index) {
    report |> without(index) |> differences |> is_gradual
  })
}

fn is_monotonic(diffs: List(Int)) -> Bool {
  case diffs |> list.map(sgn) |> list.unique {
    [1] | [-1] -> True
    _ -> False
  }
}

fn is_gradual(diffs: List(Int)) -> Bool {
  diffs
  |> list.map(int.absolute_value)
  |> list.all(fn(number) { 0 < number && number < 4 })
}

fn without(report: List(Int), index: Int) -> List(Int) {
  list.append(report |> list.take(index), report |> list.drop(index + 1))
}

fn differences(report: List(Int)) -> List(Int) {
  report
  |> list.window_by_2
  |> list.map(fn(tuple) { tuple.1 - tuple.0 })
}

fn sgn(number: Int) -> Int {
  int.compare(number, 0) |> order.to_int
}
