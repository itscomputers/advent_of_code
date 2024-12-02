import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleamy/priority_queue as pq

import graph.{type Graph}

type Node(a) {
  Infinity(value: a)
  Node(value: a, dist: Int)
}

pub type Algorithm {
  BFS
  Dijkstra
}

type SearchQueue(a) {
  Queue(inner: Deque(Node(a)))
  PriorityQueue(inner: pq.Queue(Node(a)))
}

pub opaque type Search(a) {
  Search(
    graph: Graph(a),
    source: a,
    prev: Dict(a, a),
    nodes: Dict(a, Node(a)),
    queue: SearchQueue(a),
    visited: Set(a),
    complete: Bool,
  )
}

pub fn path(
  gr: Graph(a),
  from source: a,
  to target: a,
  using algorithm: Algorithm,
) -> Option(List(a)) {
  gr
  |> new(from: source, using: algorithm)
  |> search(for: Some(target))
  |> build_path(to: target)
  |> validate_path(from: source)
}

pub fn distances(
  gr: Graph(a),
  from source: a,
  using algorithm: Algorithm,
) -> Dict(a, Int) {
  gr
  |> new(from: source, using: algorithm)
  |> search(for: None)
  |> get_distances
}

fn new(gr: Graph(a), from source: a, using algorithm: Algorithm) -> Search(a) {
  let node = Node(source, 0)
  Search(
    gr,
    source,
    prev: dict.new(),
    nodes: dict.new() |> dict.insert(source, node),
    queue: algorithm |> empty_queue |> push(node),
    visited: set.new(),
    complete: False,
  )
}

fn empty_queue(algorithm: Algorithm) -> SearchQueue(a) {
  case algorithm {
    BFS -> Queue(deque.new())
    Dijkstra -> PriorityQueue(pq.new(compare))
  }
}

fn get_distances(s: Search(a)) -> Dict(a, Int) {
  s.nodes |> dict.map_values(get_distance)
}

fn get_distance(_vertex: a, node: Node(a)) -> Int {
  case node {
    Infinity(_) -> -1
    Node(_, dist) -> dist
  }
}

fn validate_path(path: List(a), from source: a) -> Option(List(a)) {
  case path {
    [first, ..] if first == source -> Some(path)
    _ -> None
  }
}

fn build_path(s: Search(a), to target: a) -> List(a) {
  s |> path_loop([target])
}

fn path_loop(s: Search(a), path: List(a)) -> List(a) {
  case
    path
    |> list.first
    |> result.try(fn(vertex) { s.prev |> dict.get(vertex) })
  {
    Ok(prev) -> path_loop(s, [prev, ..path])
    Error(_) -> path
  }
}

fn search(s: Search(a), for target: Option(a)) -> Search(a) {
  case s.complete {
    True -> s
    False ->
      case s.queue |> pop {
        Error(_) -> Search(..s, complete: True)
        Ok(#(Infinity(_), _)) -> Search(..s, complete: True)
        Ok(#(Node(vertex, _), queue)) -> {
          s.graph
          |> graph.neighbors(of: vertex)
          |> list.filter(fn(neighbor) { !set.contains(s.visited, neighbor) })
          |> list.fold(
            from: Search(..s, queue: queue),
            with: process_neighbor(vertex),
          )
          |> mark_visited(vertex, target)
          |> search(for: target)
        }
      }
  }
}

fn process_neighbor(vertex: a) -> fn(Search(a), a) -> Search(a) {
  fn(s, neighbor) {
    let vertex_node = s |> get_node(vertex)
    let original_node = s |> get_node(neighbor)
    let updated_node = case vertex_node, original_node {
      Node(_, dist), _ ->
        Node(
          value: neighbor,
          dist: dist + graph.weight(s.graph, vertex, neighbor),
        )
      _, _ -> original_node
    }
    case updated_node |> compare(original_node) {
      Lt ->
        Search(
          ..s,
          prev: s.prev |> dict.insert(neighbor, vertex),
          nodes: s.nodes |> dict.insert(neighbor, updated_node),
          queue: s.queue |> push(updated_node),
        )
      _ -> s
    }
  }
}

fn mark_visited(s: Search(a), vertex: a, target: Option(a)) -> Search(a) {
  Search(
    ..s,
    visited: s.visited |> set.insert(vertex),
    complete: target == Some(vertex),
  )
}

fn pop(queue: SearchQueue(a)) -> Result(#(Node(a), SearchQueue(a)), Nil) {
  case queue {
    Queue(inner) ->
      inner
      |> deque.pop_front
      |> result.map(fn(tuple) { #(tuple.0, Queue(tuple.1)) })
    PriorityQueue(inner) ->
      inner
      |> pq.pop
      |> result.map(fn(tuple) { #(tuple.0, PriorityQueue(tuple.1)) })
  }
}

fn push(queue: SearchQueue(a), node: Node(a)) -> SearchQueue(a) {
  case queue {
    Queue(inner) -> Queue(inner |> deque.push_back(node))
    PriorityQueue(inner) -> PriorityQueue(inner |> pq.push(node))
  }
}

fn get_node(s: Search(a), vertex: a) -> Node(a) {
  case s.nodes |> dict.get(vertex) {
    Ok(node) -> node
    Error(_) -> Infinity(vertex)
  }
}

fn compare(node: Node(a), other: Node(a)) -> Order {
  case node, other {
    Infinity(_), Infinity(_) -> Eq
    Infinity(_), _ -> Gt
    _, Infinity(_) -> Lt
    Node(_, d1), Node(_, d2) -> int.compare(d1, d2)
  }
}
