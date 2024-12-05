import gleam/dict.{type Dict}
import gleam/list

import graph.{type Graph}

type Toposort(a) {
  Toposort(
    graph: Graph(a),
    stack: List(a),
    indegree: Dict(a, Int),
    sorted: List(a),
  )
}

pub fn sort(gr: Graph(a), vertices: List(a)) -> List(a) {
  gr |> new(vertices) |> loop |> sorted |> list.reverse
}

fn new(gr: Graph(a), vertices: List(a)) -> Toposort(a) {
  let indegree = gr |> build_indegree(vertices)
  let stack =
    indegree
    |> dict.fold(from: [], with: fn(acc, vertex, count) {
      case count {
        0 -> [vertex, ..acc]
        _ -> acc
      }
    })
  Toposort(graph: gr, stack:, indegree:, sorted: [])
}

fn loop(toposort: Toposort(a)) -> Toposort(a) {
  case toposort.stack {
    [] -> toposort
    [vertex, ..stack] ->
      Toposort(..toposort, stack:, sorted: [vertex, ..toposort.sorted])
      |> process_vertex(vertex)
      |> loop
  }
}

fn sorted(toposort: Toposort(a)) -> List(a) {
  toposort.sorted
}

fn build_indegree(gr: Graph(a), vertices: List(a)) -> Dict(a, Int) {
  let indegree =
    vertices |> list.map(fn(vertex) { #(vertex, 0) }) |> dict.from_list
  vertices
  |> list.fold(from: indegree, with: fn(acc, vertex) {
    gr
    |> graph.neighbors(of: vertex)
    |> list.fold(from: acc, with: fn(acc, neighbor) {
      case acc |> dict.get(neighbor) {
        Ok(indegree) -> acc |> dict.insert(neighbor, indegree + 1)
        Error(_) -> acc
      }
    })
  })
}

fn process_vertex(toposort: Toposort(a), vertex: a) -> Toposort(a) {
  toposort.graph
  |> graph.neighbors(of: vertex)
  |> list.fold(from: toposort, with: process_neighbor)
}

fn process_neighbor(toposort: Toposort(a), neighbor: a) -> Toposort(a) {
  case toposort.indegree |> dict.get(neighbor) {
    Ok(1) ->
      Toposort(
        ..toposort,
        stack: [neighbor, ..toposort.stack],
        indegree: toposort.indegree
          |> dict.delete(neighbor),
      )
    Ok(count) ->
      Toposort(
        ..toposort,
        indegree: toposort.indegree
          |> dict.insert(neighbor, count - 1),
      )
    _ -> toposort
  }
}
