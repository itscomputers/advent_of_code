import gleam/dict.{type Dict}
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}

import graph/bfs
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

pub fn connected_component(gr: Graph(a), of vertex: a) -> List(a) {
  gr |> search.distances(from: vertex, using: BFS) |> dict.keys
}

pub fn is_sorted(gr: Graph(a), vertices: List(a)) -> Bool {
  gr |> is_sorted_loop(vertices, set.new())
}

pub fn condense(
  gr: Graph(a),
  from sources: List(a),
  to targets: List(a),
) -> Graph(a) {
  let targets = set.from_list(targets)
  sources
  |> list.fold(from: graph.new(), with: fn(acc, src) {
    let targets = targets |> set.delete(src)
    bfs.distances(gr, from: src, until: set.contains(targets, _))
    |> dict.take(targets |> set.to_list)
    |> dict.fold(from: acc, with: fn(acc, dst, weight) {
      acc |> graph.add_weighted(from: src, to: dst, weight:)
    })
  })
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

pub fn best_path_points(
  gr: Graph(a),
  to target: a,
  using distances: Dict(a, Int),
) -> Set(a) {
  best_path_points_loop(gr, [target], set.new(), distances)
}

fn best_path_points_loop(
  gr: Graph(a),
  vertices: List(a),
  visited: Set(a),
  distances: Dict(a, Int),
) -> Set(a) {
  case vertices {
    [] -> visited
    [vertex, ..vertices] -> {
      let vertices =
        gr
        |> graph.incoming(to: vertex)
        |> list.fold(from: vertices, with: fn(acc, incoming) {
          case distances |> dict.get(vertex), distances |> dict.get(incoming) {
            Error(_), _ -> acc
            _, Error(_) -> acc
            Ok(d1), Ok(d0) ->
              case d1 - d0 == gr |> graph.weight(incoming, vertex) {
                True ->
                  case acc |> list.contains(incoming) {
                    True -> acc
                    False -> list.append(acc, [incoming])
                  }
                False -> acc
              }
          }
        })
      best_path_points_loop(
        gr,
        vertices,
        visited |> set.insert(vertex),
        distances,
      )
    }
  }
}
