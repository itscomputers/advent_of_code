import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}

import graph/graph.{type Graph}
import graph/search
import grid.{type Grid}
import point.{type Point}

type Map {
  Map(
    grid: Grid,
    graph: Graph(Point),
    distance_lookup: Dict(Point, Dict(Point, Int)),
  )
}

type TrailCounter {
  TrailCounter(map: Map, source: Point, target: Point, counts: Dict(Point, Int))
}

pub fn main(input: String, part: Part) -> String {
  input |> build_map |> score(part) |> int.to_string
}

fn build_map(input: String) -> Map {
  Map(
    grid: input |> grid.new(),
    graph: graph.new(),
    distance_lookup: dict.new(),
  )
  |> add_graph
  |> add_all_distances
}

fn score(map: Map, part: Part) -> Int {
  map.distance_lookup
  |> dict.fold(from: 0, with: fn(acc, pt, distances) {
    acc + trail_score(map, pt, distances, part)
  })
}

fn trail_score(
  map: Map,
  trailhead: Point,
  distances: Dict(Point, Int),
  part: Part,
) -> Int {
  case part {
    PartOne -> distances |> dict.size
    PartTwo ->
      distances
      |> dict.fold(from: 0, with: fn(acc, peak, _) {
        acc + trail_count(map, trailhead, peak)
      })
  }
}

fn add_graph(map: Map) -> Map {
  map.grid |> grid.fold(from: map, with: add_edges)
}

fn add_edges(map: Map, pt: Point, _str: String) -> Map {
  let graph =
    map
    |> neighbors(of: pt)
    |> list.fold(from: map.graph, with: fn(acc, neighbor) {
      acc |> graph.add(pt, neighbor)
    })
  Map(..map, graph:)
}

fn neighbors(map: Map, of pt: Point) -> List(Point) {
  case map |> value_at(pt: pt) {
    None -> []
    Some(value) ->
      pt
      |> point.strict_neighbors
      |> list.filter(fn(neighbor) {
        case map |> value_at(pt: neighbor) {
          Some(neighbor_value) -> neighbor_value - value == 1
          None -> False
        }
      })
  }
}

fn add_all_distances(map: Map) -> Map {
  map.grid
  |> grid.filter(fn(str) { str == "0" })
  |> list.fold(from: map, with: add_distances)
}

fn add_distances(map: Map, from pt: Point) -> Map {
  let distances =
    map.graph
    |> search.distances(from: pt, using: search.BFS)
    |> dict.filter(fn(target, _) { map |> value_at(target) == Some(9) })
  let distance_lookup = map.distance_lookup |> dict.insert(pt, distances)
  Map(..map, distance_lookup:)
}

fn trail_count(map: Map, source: Point, target: Point) -> Int {
  trail_count_loop(
    TrailCounter(map:, source:, target:, counts: dict.new()),
    source,
  )
  |> get_count(for: source)
}

fn trail_count_loop(counter: TrailCounter, current: Point) -> TrailCounter {
  let counts =
    counter.counts |> dict.insert(current, counter |> computed_count(current))
  TrailCounter(..counter, counts:)
}

fn computed_count(counter: TrailCounter, current: Point) -> Int {
  case counter.target == current {
    True -> 1
    False ->
      counter.map
      |> neighbors(of: current)
      |> list.map(fn(neighbor) {
        trail_count_loop(counter, neighbor) |> get_count(for: neighbor)
      })
      |> int.sum
  }
}

fn get_count(counter: TrailCounter, for pt: Point) -> Int {
  case counter.counts |> dict.get(pt) {
    Ok(count) -> count
    Error(_) -> 0
  }
}

fn value_at(map: Map, pt pt: Point) -> Option(Int) {
  map.grid
  |> grid.get(pt)
  |> option.map(int.parse)
  |> option.map(option.from_result)
  |> option.flatten
}
