import args.{type Part, PartOne, PartTwo}
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/task
import gleam/string

import counter.{type Counter}
import util

type Strategy {
  Forward
  Backward
}

type Design {
  Design(
    towel: String,
    patterns: List(String),
    strategy: Strategy,
    remaining: Counter(String),
    count: Int,
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> {
      input
      |> designs(Backward)
      |> list.count(fn(designer) { designer.count > 0 })
      |> int.to_string
      |> util.println("backward")
    }
    PartTwo -> {
      input
      |> designs(Backward)
      |> list.fold(from: 0, with: fn(acc, designer) { acc + designer.count })
      |> int.to_string
      |> util.println("backward")
    }
  }
}

fn designs(input: String, strategy: Strategy) -> List(Design) {
  let assert [pattern_str, towel_str] = input |> util.blocks
  let patterns = pattern_str |> string.split(", ")
  towel_str
  |> util.lines
  |> list.map(fn(towel) {
    Design(
      towel:,
      patterns:,
      strategy:,
      remaining: counter.from_list([towel]),
      count: 0,
    )
  })
  |> list.map(loop)
  // |> list.map(fn(designer) {
  //   task.async(fn() { designer |> loop })
  // })
  // |> list.map(task.await_forever)
}

fn loop(design: Design) -> Design {
  case design.remaining |> counter.is_empty {
    True -> design
    False ->
      design.remaining
      |> counter.fold(from: design, with: handler)
      |> loop
  }
}

fn handler(design: Design, str: String, count: Int) -> Design {
  design.patterns
  |> list.fold(from: design, with: fn(acc, pattern) {
    acc |> pattern_handler(str, count, pattern)
  })
}

fn pattern_handler(
  design: Design,
  str: String,
  count: Int,
  pattern: String,
) -> Design {
  let remaining = design.remaining |> counter.drop([str])
  case str == pattern, leftover(str, pattern, design.strategy) {
    True, _ -> {
      Design(..design, remaining:, count: design.count + count)
    }
    False, Some(leftover) -> {
      let remaining = remaining |> counter.increment(leftover, by: count)
      Design(..design, remaining:)
    }
    _, _ -> {
      Design(..design, remaining:)
    }
  }
}

fn leftover(str: String, pattern: String, strategy: Strategy) -> Option(String) {
  case checker(strategy)(str, pattern) {
    True -> Some(dropper(strategy)(str, pattern))
    False -> None
  }
}

fn checker(strategy: Strategy) -> fn(String, String) -> Bool {
  case strategy {
    Forward -> string.starts_with
    Backward -> string.ends_with
  }
}

fn dropper(strategy: Strategy) -> fn(String, String) -> String {
  let drop = case strategy {
    Forward -> string.drop_start
    Backward -> string.drop_end
  }
  fn(s1, s2) { drop(s1, s2 |> string.length) }
}
