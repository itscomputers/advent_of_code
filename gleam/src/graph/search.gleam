import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/result
import gleam/set.{type Set}
import gleamy/priority_queue as pq

import graph/graph.{type Graph}

type Node(a) {
  Node(vertex: a, dist: Distance)
}

type Distance {
  Infinity
  Distance(value: Int)
}

pub type Algorithm {
  BFS
  Dijkstra
}

type Queue(a) {
  Queue(inner: Deque(Node(a)))
  PriorityQueue(inner: pq.Queue(Node(a)))
}

pub opaque type Search(a) {
  Search(
    graph: Graph(a),
    source: a,
    prev: Dict(a, a),
    nodes: Dict(a, Node(a)),
    queue: Queue(a),
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

pub fn distance(
  gr: Graph(a),
  from source: a,
  to target: a,
  using algorithm: Algorithm,
) -> Int {
  gr
  |> new(from: source, using: algorithm)
  |> search(for: Some(target))
  |> get_node(target)
  |> get_distance(target, _)
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
  let node = Node(source, Distance(0))
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

fn empty_queue(algorithm: Algorithm) -> Queue(a) {
  case algorithm {
    BFS -> Queue(deque.new())
    Dijkstra -> PriorityQueue(pq.new(compare))
  }
}

fn get_distances(s: Search(a)) -> Dict(a, Int) {
  s.nodes |> dict.map_values(get_distance)
}

fn get_distance(_vertex: a, node: Node(a)) -> Int {
  case node.dist {
    Infinity -> -1
    Distance(dist) -> dist
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
        Ok(#(Node(_, Infinity), _)) -> Search(..s, complete: True)
        Ok(#(Node(vertex, _), queue)) ->
          Search(..s, queue:)
          |> process(vertex)
          |> mark_visited(vertex)
          |> check_complete(vertex, target)
          |> search(for: target)
      }
  }
}

fn process(s: Search(a), vertex: a) -> Search(a) {
  s |> loop(vertex, s |> neighbors(of: vertex))
}

fn loop(s: Search(a), vertex: a, neighbors: List(a)) -> Search(a) {
  case neighbors {
    [neighbor, ..rest] ->
      s
      |> process_edge(from: vertex, to: neighbor)
      |> loop(vertex, rest)
    _ -> s
  }
}

fn process_edge(s: Search(a), from vertex: a, to neighbor: a) -> Search(a) {
  case s.visited |> set.contains(neighbor) {
    True -> s
    False -> s |> update(vertex, neighbor)
  }
}

fn update(s: Search(a), vertex: a, neighbor: a) -> Search(a) {
  let vertex_node = s |> get_node(vertex)
  let original_node = s |> get_node(neighbor)
  let updated_node = case vertex_node.dist {
    Infinity -> original_node
    Distance(dist) ->
      Node(neighbor, Distance(dist + weight(s, from: vertex, to: neighbor)))
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

fn check_complete(s: Search(a), vertex: a, target: Option(a)) -> Search(a) {
  Search(..s, complete: target == Some(vertex))
}

fn mark_visited(s: Search(a), vertex: a) -> Search(a) {
  Search(..s, visited: s.visited |> set.insert(vertex))
}

fn pop(queue: Queue(a)) -> Result(#(Node(a), Queue(a)), Nil) {
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

fn push(queue: Queue(a), node: Node(a)) -> Queue(a) {
  case queue {
    Queue(inner) -> Queue(inner |> deque.push_back(node))
    PriorityQueue(inner) -> PriorityQueue(inner |> pq.push(node))
  }
}

fn neighbors(s: Search(a), of vertex: a) -> List(a) {
  s.graph |> graph.neighbors(of: vertex)
}

fn weight(s: Search(a), from source: a, to target: a) -> Int {
  s.graph |> graph.weight(from: source, to: target)
}

fn get_node(s: Search(a), vertex: a) -> Node(a) {
  case s.nodes |> dict.get(vertex) {
    Ok(node) -> node
    Error(_) -> Node(vertex, Infinity)
  }
}

fn compare(node: Node(a), other: Node(a)) -> Order {
  case node.dist, other.dist {
    Infinity, Infinity -> Eq
    Infinity, _ -> Gt
    _, Infinity -> Lt
    Distance(d1), Distance(d2) -> int.compare(d1, d2)
  }
}
