import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}

import args.{type Part, PartOne, PartTwo}
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
  |> dict.fold(from: 0, with: fn(acc, entry, initial) {
    let in_range = fn(exit, _) { point.distance(entry, exit) <= radius }
    let valid_cheat = fn(exit, remaining) {
      initial + point.distance(entry, exit) + remaining
      <= race.distance - threshold
    }
    race.target_distances
    |> dict.filter(in_range)
    |> dict.filter(valid_cheat)
    |> dict.size
    |> int.add(acc)
  })
}

fn distances(graph: Graph(Point), vertex: Point) -> Dict(Point, Int) {
  graph |> search.distances(from: vertex, using: search.BFS)
}
