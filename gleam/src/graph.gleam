import gleam/dict.{type Dict}
import gleam/list
import gleam/string

import regex

pub opaque type Graph(a) {
  Graph(lookup: Dict(a, Dict(a, Int)))
}

pub fn new() -> Graph(a) {
  Graph(dict.new())
}

pub fn from_string(str: String, separator: String) -> Graph(String) {
  str
  |> string.split("\n")
  |> list.map(regex.split(_, " *" <> separator <> " *"))
  |> list.map(fn(vertices) {
    case vertices {
      [source, target] -> #(source, target)
      _ -> #("", "")
    }
  })
  |> list.filter(fn(tuple) { tuple != #("", "") })
  |> from_list
}

pub fn from_list(edges: List(#(a, a))) -> Graph(a) {
  edges
  |> list.fold(from: new(), with: fn(graph, edge) {
    graph |> add(edge.0, edge.1)
  })
}

pub fn from_weighted_list(edges: List(#(a, a, Int))) -> Graph(a) {
  edges
  |> list.fold(from: new(), with: fn(graph, edge) {
    graph |> add_weighted(edge.0, edge.1, edge.2)
  })
}

pub fn add(graph: Graph(a), source: a, target: a) -> Graph(a) {
  graph |> add_weighted(source, target, 1)
}

pub fn add_weighted(
  graph: Graph(a),
  source: a,
  target: a,
  weight: Int,
) -> Graph(a) {
  Graph(
    lookup: graph.lookup
    |> dict.insert(
      source,
      graph
        |> get(source)
        |> dict.insert(target, weight),
    ),
  )
}

pub fn neighbors(graph: Graph(a), vertex: a) -> List(a) {
  graph |> get(vertex) |> dict.keys
}

pub fn adjacent(graph: Graph(a), source: a, target: a) -> Bool {
  graph |> weight(source, target) != -1
}

pub fn weight(graph: Graph(a), source: a, target: a) -> Int {
  case graph |> get(source) |> dict.get(target) {
    Ok(weight) -> weight
    Error(_) -> -1
  }
}

fn get(graph: Graph(a), vertex: a) -> Dict(a, Int) {
  case graph.lookup |> dict.get(vertex) {
    Ok(dct) -> dct
    Error(_) -> dict.new()
  }
}
