import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}

import graph/graph.{type Graph}
import graph/search.{BFS}
import graph/toposort

pub fn is_cyclic(gr: Graph(a)) -> Bool {
  case gr |> toposort.sort {
    Some(_) -> False
    None -> True
  }
}

pub fn are_connected(gr: Graph(a), source: a, target: a) -> Bool {
  case gr |> search.path(from: source, to: target, using: BFS) {
    Some(_) -> True
    None -> False
  }
}

pub fn is_sorted(gr: Graph(a), vertices: List(a)) -> Bool {
  gr |> is_sorted_loop(vertices, set.new())
}

fn is_sorted_loop(gr: Graph(a), vertices: List(a), visited: Set(a)) -> Bool {
  case vertices {
    [] -> True
    [vertex, ..vertices] ->
      case
        gr
        |> graph.neighbors(of: vertex)
        |> list.any(set.contains(visited, _))
      {
        True -> False
        False -> gr |> is_sorted_loop(vertices, visited |> set.insert(vertex))
      }
  }
}
