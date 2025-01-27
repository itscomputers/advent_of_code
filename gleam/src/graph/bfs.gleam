import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/list
import gleam/set.{type Set}

import graph/graph.{type Graph}

type BFS(a) {
  BFS(
    graph: Graph(a),
    source: a,
    queue: Deque(a),
    prev: Dict(a, a),
    dist: Dict(a, Int),
    visited: Set(a),
  )
}

pub fn distances(
  graph: Graph(a),
  from source: a,
  until predicate: fn(a) -> Bool,
) -> Dict(a, Int) {
  graph
  |> new(from: source)
  |> search(until: predicate)
  |> fn(bfs) { bfs.dist }
}

fn new(graph: Graph(a), from source: a) -> BFS(a) {
  let queue = deque.new() |> deque.push_back(source)
  let dist = dict.new() |> dict.insert(source, 0)
  BFS(graph:, source:, queue:, prev: dict.new(), dist:, visited: set.new())
}

fn search(bfs: BFS(a), until predicate: fn(a) -> Bool) -> BFS(a) {
  case bfs.queue |> deque.pop_front {
    Error(_) -> bfs
    Ok(#(vertex, queue)) -> {
      case bfs.visited |> set.contains(vertex) || predicate(vertex) {
        True -> BFS(..bfs, queue:)
        False ->
          BFS(..bfs, queue:)
          |> process(vertex)
          |> mark_visited(vertex)
      }
      |> search(predicate)
    }
  }
}

fn process(bfs: BFS(a), vertex: a) -> BFS(a) {
  let assert Ok(distance) = bfs.dist |> dict.get(vertex)
  bfs.graph
  |> graph.neighbors(of: vertex)
  |> list.fold(from: bfs, with: fn(acc, neighbor) {
    case
      acc.visited |> set.contains(neighbor)
      || acc.prev |> dict.has_key(neighbor)
    {
      True -> acc
      False -> {
        let prev = acc.prev |> dict.insert(neighbor, vertex)
        let dist = acc.dist |> dict.insert(neighbor, distance + 1)
        let queue = acc.queue |> deque.push_back(neighbor)
        BFS(..acc, queue:, prev:, dist:)
      }
    }
  })
}

fn mark_visited(bfs: BFS(a), vertex: a) -> BFS(a) {
  let visited = bfs.visited |> set.insert(vertex)
  BFS(..bfs, visited:)
}
