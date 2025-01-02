import args.{type Part, PartOne, PartTwo}
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set.{type Set}

import graph/graph.{type Graph}
import graph/search
import grid.{type Grid}
import point.{type Point}

type Neighbors {
  Neighbors(
    race: Race,
    point: Point,
    distance: Int,
    queue: Deque(Point),
    visited: Set(Point),
    neighbors: Set(Point),
  )
}

pub type Race {
  Race(
    grid: Grid,
    source_distances: Dict(Point, Int),
    target_distances: Dict(Point, Int),
    cheat: Cheat,
  )
}

pub type Cheat {
  Cheat(radius: Int, distance: Int)
}

pub fn main(input: String, part: Part) -> String {
  input |> race(part, 100) |> cheat_count |> int.to_string
}

pub fn race(input: String, part: Part, min_cheat: Int) -> Race {
  let grid = input |> grid.new
  let assert Some(source) = grid |> grid.find(fn(ch) { ch == "S" })
  let assert Some(target) = grid |> grid.find(fn(ch) { ch == "E" })
  let graph =
    grid
    |> grid.filter(fn(ch) { [".", "S", "E"] |> list.contains(ch) })
    |> list.fold(from: graph.new(), with: fn(acc, pt) {
      pt
      |> point.strict_neighbors
      |> list.fold(from: acc, with: fn(acc, neighbor) {
        case grid |> grid.get(neighbor) {
          Some(".") | Some("E") | Some("S") -> acc |> graph.add(pt, neighbor)
          _ -> acc
        }
      })
    })
  let source_distances = distances(graph, source)
  let target_distances = distances(graph, target)
  let assert Ok(distance) = source_distances |> dict.get(target)
  let distance = distance - min_cheat
  let radius = case part {
    PartOne -> 2
    PartTwo -> 20
  }
  let cheat = Cheat(radius:, distance:)
  Race(grid:, source_distances:, target_distances:, cheat:)
}

pub fn cheat_count(race: Race) -> Int {
  race.source_distances
  |> dict.fold(from: 0, with: fn(acc, pt, dist) {
    acc + cheat_count_at(race, pt, dist)
  })
}

fn cheat_count_at(race: Race, vertex: Point, distance: Int) -> Int {
  race
  |> neighbors(vertex, distance)
  |> list.length
}

fn distances(graph: Graph(Point), vertex: Point) -> Dict(Point, Int) {
  graph |> search.distances(from: vertex, using: search.BFS)
}

fn neighbors(race: Race, point: Point, distance: Int) -> List(Point) {
  Neighbors(
    race:,
    point:,
    distance:,
    queue: deque.from_list([point]),
    visited: set.new(),
    neighbors: set.new(),
  )
  |> loop
  |> fn(n) { n.neighbors |> set.to_list }
}

fn loop(n: Neighbors) -> Neighbors {
  case n.queue |> deque.pop_front {
    Error(_) -> n
    Ok(#(vertex, queue)) ->
      case n |> should_skip(vertex) {
        True -> Neighbors(..n, queue:)
        False -> {
          let visited = n.visited |> set.insert(vertex)
          vertex
          |> point.strict_neighbors
          |> list.fold(
            from: Neighbors(..n, queue:, visited:),
            with: process_neighbor,
          )
        }
      }
      |> loop
  }
}

fn process_neighbor(n: Neighbors, neighbor: Point) -> Neighbors {
  let is_exit = is_open(n, neighbor) && is_cheat(n, neighbor)
  let should_enqueue = n.race.grid |> grid.get(neighbor) == Some("#")
  case is_exit, should_enqueue {
    True, _ -> Neighbors(..n, neighbors: n.neighbors |> set.insert(neighbor))
    _, True -> Neighbors(..n, queue: n.queue |> deque.push_back(neighbor))
    _, _ -> n
  }
}

fn should_skip(n: Neighbors, vertex: Point) -> Bool {
  set.contains(n.visited, vertex)
  || point.distance(vertex, n.point) >= n.race.cheat.radius
}

fn is_open(n: Neighbors, vertex: Point) -> Bool {
  [Some("."), Some("S"), Some("E")]
  |> list.contains(n.race.grid |> grid.get(vertex))
}

fn is_cheat(n: Neighbors, vertex: Point) -> Bool {
  case n.race.target_distances |> dict.get(vertex) {
    Error(_) -> False
    Ok(distance) ->
      distance + n.distance + point.distance(vertex, n.point)
      <= n.race.cheat.distance
  }
}
