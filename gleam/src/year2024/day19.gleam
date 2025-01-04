import gleam/int
import gleam/list
import gleam/string

import args.{type Part, PartOne, PartTwo}
import counter.{type Counter}
import util

type DesignCounter {
  DesignCounter(
    designs: List(String),
    patterns: List(String),
    counter: Counter(String),
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> design_counter |> possible_count |> int.to_string
    PartTwo -> input |> design_counter |> total_count |> int.to_string
  }
}

fn possible_count(design_counter: DesignCounter) -> Int {
  design_counter
  |> design_counts
  |> counter.prune
  |> counter.size
}

fn total_count(design_counter: DesignCounter) -> Int {
  design_counter
  |> design_counts
  |> counter.values
  |> int.sum
}

fn design_counts(design_counter: DesignCounter) -> Counter(String) {
  design_counter.counter
  |> counter.take(design_counter.designs)
}

fn design_counter(input: String) -> DesignCounter {
  let assert [p_str, d_str] = input |> util.blocks
  let patterns = p_str |> string.split(", ")
  let designs = d_str |> util.lines
  let counter = counts(designs, patterns)
  DesignCounter(designs:, patterns:, counter:)
}

fn counts(designs: List(String), patterns: List(String)) -> Counter(String) {
  designs
  |> list.fold(from: counter.new(), with: fn(acc, design) {
    counter_loop(design, patterns, acc)
  })
}

fn counter_loop(
  design: String,
  patterns: List(String),
  memo: Counter(String),
) -> Counter(String) {
  case design == "" {
    True -> memo
    False ->
      case memo |> counter.has_key(design) {
        True -> memo
        False -> {
          patterns
          |> list.filter(contains(design, _))
          |> list.fold(from: memo, with: fn(acc, pattern) {
            handle(design, patterns, pattern, acc)
          })
        }
      }
  }
}

fn handle(
  design: String,
  patterns: List(String),
  pattern: String,
  memo: Counter(String),
) -> Counter(String) {
  case design == pattern {
    True -> memo |> counter.increment(design, by: 1)
    False ->
      case design |> contains(pattern) {
        False -> memo
        True -> {
          let sub = design |> subdesign(pattern)
          let memo = counter_loop(sub, patterns, memo)
          memo
          |> counter.increment(design, by: memo |> counter.get(sub))
        }
      }
  }
}

fn contains(design: String, pattern: String) -> Bool {
  design |> string.ends_with(pattern)
}

fn subdesign(design: String, pattern: String) -> String {
  design |> string.drop_end(string.length(pattern))
}
