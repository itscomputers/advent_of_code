import args.{type Part, PartOne, PartTwo}
import gleam/deque.{type Deque}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}

import graph/graph.{type Graph}
import graph/search
import grid.{type Grid}
import point.{type Point}

pub type Race {
  Race(
    grid: Grid,
    source_distances: Dict(Point, Int),
    target_distances: Dict(Point, Int),
    distance: Int,
  )
}

type Cheat {
  Cheat(
    race: Race,
    point: Point,
    max_distance: Int,
    radius: Int,
    queue: Deque(Point),
    distances: Dict(Point, Int),
    neighbors: Set(Point),
  )
}

pub fn main(input: String, part: Part) -> String {
  input |> race |> count(part, 100) |> int.to_string
}

pub fn race(input: String) -> Race {
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
  Race(grid:, source_distances:, target_distances:, distance:)
}

pub fn count(race: Race, part: Part, threshold: Int) -> Int {
  let radius = case part {
    PartOne -> 2
    PartTwo -> 20
  }
  race.source_distances
  |> dict.fold(from: 0, with: fn(acc, point, distance) {
    Cheat(
      race:,
      point:,
      max_distance: race.distance - distance - threshold,
      radius:,
      queue: deque.from_list([point]),
      distances: dict.from_list([#(point, 0)]),
      neighbors: set.new(),
    )
    |> cheat_search
    |> cheat_count
    |> int.add(acc)
  })
}

fn cheat_count(cheat: Cheat) -> Int {
  cheat.neighbors |> set.size
}

fn cheat_search(cheat: Cheat) -> Cheat {
  case cheat.queue |> deque.pop_front {
    Error(_) -> cheat
    Ok(#(vertex, queue)) ->
      Cheat(..cheat, queue:)
      |> process(vertex)
      |> cheat_search
  }
}

fn process(cheat: Cheat, vertex: Point) -> Cheat {
  let assert Ok(distance) = cheat.distances |> dict.get(vertex)
  case distance == cheat.radius {
    True -> cheat
    False ->
      vertex
      |> point.strict_neighbors
      |> list.fold(from: cheat, with: fn(acc, neighbor) {
        case
          acc.distances |> dict.get(neighbor),
          acc.race.grid |> grid.get(neighbor)
        {
          Ok(_), _ | _, None -> acc
          _, Some("#") ->
            acc
            |> add_to_queue(neighbor)
            |> set_distance(neighbor, distance + 1)
          _, Some(_) ->
            acc
            |> add_to_neighbors(neighbor, distance)
            |> add_to_queue(neighbor)
            |> set_distance(neighbor, distance + 1)
        }
      })
  }
}

fn add_to_queue(cheat: Cheat, neighbor: Point) -> Cheat {
  let queue = cheat.queue |> deque.push_back(neighbor)
  Cheat(..cheat, queue:)
}

fn add_to_neighbors(cheat: Cheat, neighbor: Point, distance: Int) -> Cheat {
  case cheat.race.target_distances |> dict.get(neighbor) {
    Ok(remaining) -> {
      case distance + remaining < cheat.max_distance {
        True -> {
          let neighbors = cheat.neighbors |> set.insert(neighbor)
          Cheat(..cheat, neighbors:)
        }
        False -> cheat
      }
    }
    Error(_) -> cheat
  }
}

fn set_distance(cheat: Cheat, vertex: Point, distance: Int) -> Cheat {
  let distances = cheat.distances |> dict.insert(vertex, distance)
  Cheat(..cheat, distances:)
}

fn distances(graph: Graph(Point), vertex: Point) -> Dict(Point, Int) {
  graph |> search.distances(from: vertex, using: search.BFS)
}
