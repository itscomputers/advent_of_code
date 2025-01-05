import gleam/function
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/otp/task
import gleam/pair
import gleam/string

import args.{type Part, PartOne, PartTwo}
import graph/graph.{type Graph}
import util

type Cut {
  Cut(groups: List(List(String)), edges: List(#(String, String)))
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> build_graph |> min_cut(50) |> int.to_string
    PartTwo -> "the end"
  }
}

fn min_cut(graph: Graph(String), iterations: Int) -> Int {
  let cut =
    list.range(1, iterations)
    |> list.map(fn(_) { task.async(fn() { min_cut_candidate(graph) }) })
    |> list.map(task.await_forever)
    |> function.tap(fn(cuts) {
      cuts
      |> list.map(fn(c) { c.edges |> list.length })
      |> list.unique
      |> list.sort(by: int.compare)
      |> util.println("edges")
    })
    |> list.fold(from: Cut([], []), with: fn(acc, cut) {
      let cut_size = cut.edges |> list.length
      let acc_size = acc.edges |> list.length
      case acc, cut_size < acc_size {
        Cut([], []), _ -> cut
        _, False -> acc
        _, True -> cut
      }
    })
  util.println(cut.edges |> list.length, "min cut")
  cut.groups
  |> list.map(list.length)
  |> int.product
}

fn min_cut_candidate(graph: Graph(String)) -> Cut {
  let contracted = graph |> contraction
  let assert [group1, group2] =
    contracted
    |> graph.edges
    |> list.map(pair.first)
    |> list.map(string.split(_, "|"))
  let edges =
    graph
    |> graph.edges
    |> list.filter(fn(edge) {
      let #(s, t) = edge
      list.contains(group1, s)
      && list.contains(group2, t)
      || list.contains(group2, s)
      && list.contains(group1, t)
    })
  Cut(groups: [group1, group2], edges:)
}

fn contraction(graph: Graph(String)) -> Graph(String) {
  case graph |> graph.edges |> list.length <= 2 {
    True -> graph
    False -> graph |> contract(graph |> random_edge) |> contraction
  }
}

fn build_graph(input: String) -> Graph(String) {
  input
  |> util.lines
  |> list.fold(from: graph.new(), with: fn(acc, line) {
    let assert [source, targets] = line |> string.split(": ")
    targets
    |> string.split(" ")
    |> list.fold(from: acc, with: fn(acc, target) {
      acc
      |> graph.add(source, target)
      |> graph.add(target, source)
    })
  })
}

fn contract(
  graph: Graph(String),
  edge: Option(#(String, String)),
) -> Graph(String) {
  case edge {
    Some(#(s, t)) -> {
      let st = s <> "|" <> t
      graph
      |> graph.remove(s, t)
      |> graph.remove(t, s)
      |> graph.replace(s, with: st)
      |> graph.replace(t, with: st)
    }
    None -> graph
  }
}

fn random_edge(graph: Graph(String)) -> Option(#(String, String)) {
  let edges = graph |> graph.edges
  let index = edges |> list.length |> int.random
  edges |> list.drop(index) |> list.first |> option.from_result
}
