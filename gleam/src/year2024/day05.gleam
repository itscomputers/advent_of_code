import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

import graph/graph.{type Graph}
import graph/toposort
import graph/util as graph_util
import util

type SafetyManual {
  SafetyManual(graph: Graph(String), updates: List(List(String)))
}

pub fn main(input: String, part: Part) -> String {
  input
  |> safety_manual
  |> fn(sf) {
    case part {
      PartOne -> sf |> filter(ordered) |> middle_sum |> int.to_string
      PartTwo -> sf |> filter(unordered) |> order |> middle_sum |> int.to_string
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

fn ordered(manual: SafetyManual, update: List(String)) -> Bool {
  graph_util.is_sorted(manual.graph, update)
}

fn unordered(manual: SafetyManual, update: List(String)) -> Bool {
  !ordered(manual, update)
}

fn filter(
  manual: SafetyManual,
  predicate: fn(SafetyManual, List(String)) -> Bool,
) -> SafetyManual {
  SafetyManual(
    ..manual,
    updates: manual.updates |> list.filter(predicate(manual, _)),
  )
}

fn order(manual: SafetyManual) -> SafetyManual {
  SafetyManual(
    ..manual,
    updates: manual.updates |> list.map(order_update(manual, _)),
  )
}

fn order_update(manual: SafetyManual, update: List(String)) -> List(String) {
  manual.graph |> graph.subgraph(update) |> toposort.unsafe_sort
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
