import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

import graph.{type Graph}
import toposort
import util

type SafetyManual {
  SafetyManual(graph: Graph(String), updates: List(List(String)))
}

pub fn main(input: String, part: Part) -> String {
  input
  |> safety_manual
  |> fn(sf) {
    case part {
      PartOne -> sf |> ordered |> middle_sum |> int.to_string
      PartTwo -> sf |> unordered |> middle_sum |> int.to_string
    }
  }
}

fn safety_manual(input: String) -> SafetyManual {
  case input |> util.blocks {
    [graph_str, updates_str, ..] -> {
      SafetyManual(graph: build_graph(graph_str), updates: updates(updates_str))
    }
    _ -> panic
  }
}

fn build_graph(str: String) -> Graph(String) {
  str |> graph.from_string(sep: "|")
}

fn updates(str: String) -> List(List(String)) {
  str |> util.lines |> list.map(string.split(_, ","))
}

fn ordered(manual: SafetyManual) -> SafetyManual {
  let updates =
    manual.updates
    |> list.filter(ordered_loop(_, manual.graph, set.new()))
  SafetyManual(..manual, updates:)
}

fn unordered(manual: SafetyManual) -> SafetyManual {
  let updates =
    manual.updates
    |> list.filter(fn(update) { !ordered_loop(update, manual.graph, set.new()) })
    |> list.map(toposort.sort(manual.graph, _))
  SafetyManual(..manual, updates:)
}

fn ordered_loop(
  update: List(String),
  gr: Graph(String),
  visited: Set(String),
) -> Bool {
  case update {
    [] -> True
    [first, ..rest] ->
      case graph.neighbors(gr, first) |> list.any(set.contains(visited, _)) {
        True -> False
        False -> ordered_loop(rest, gr, visited |> set.insert(first))
      }
  }
}

fn middle_sum(manual: SafetyManual) -> Int {
  manual.updates |> list.map(middle) |> int.sum
}

fn middle(update: List(String)) {
  case
    update
    |> list.drop(list.length(update) / 2)
    |> list.first
    |> result.try(int.parse)
  {
    Ok(value) -> value
    Error(_) -> panic
  }
}
