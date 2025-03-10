import gleam/dict
import gleam/int
import gleam/list
import gleam/option
import gleam/set.{type Set}

import args.{type Part, PartOne, PartTwo}
import grid.{type Grid}
import point.{type Point}

type AntennaPair {
  AntennaPair(frequency: String, first: Point, second: Point)
}

type AntennaMap {
  AntennaMap(
    grid: Grid,
    pairs: List(AntennaPair),
    antinodes: Set(Point),
    part: Part,
  )
}

pub fn main(input: String, part: Part) -> String {
  input |> antenna_map(part) |> antinode_count |> int.to_string
}

fn antenna_map(input: String, part: Part) {
  AntennaMap(
    grid: input |> grid.new,
    part: part,
    pairs: [],
    antinodes: set.new(),
  )
  |> add_pairs
  |> add_antinodes
}

fn add_pairs(map: AntennaMap) -> AntennaMap {
  let pairs =
    map.grid
    |> grid.reverse_lookup
    |> dict.drop(["."])
    |> dict.fold(from: [], with: fn(acc, freq, points) {
      points
      |> list.combination_pairs
      |> list.map(fn(tuple) { AntennaPair(freq, tuple.0, tuple.1) })
      |> list.append(acc, _)
    })
  AntennaMap(..map, pairs:)
}

fn add_antinodes(map: AntennaMap) -> AntennaMap {
  let antinodes =
    map.pairs
    |> list.fold(from: set.new(), with: fn(acc, pair) {
      map
      |> antinodes(pair)
      |> list.filter(fn(pt) { map.grid |> grid.get(pt) |> option.is_some })
      |> set.from_list
      |> set.union(acc)
    })
  AntennaMap(..map, antinodes:)
}

fn antinode_count(map: AntennaMap) -> Int {
  map.antinodes |> set.size
}

fn antinodes(map: AntennaMap, pair: AntennaPair) -> List(Point) {
  let diff = pair.second |> point.subtract(pair.first)
  case map.part {
    PartOne -> [
      pair.first |> point.subtract(diff),
      pair.second |> point.add(diff),
    ]
    PartTwo ->
      map.grid
      |> grid.dimensions
      |> fn(pt) { int.max(pt.x, pt.y) }
      |> list.range(1, _)
      |> list.flat_map(fn(idx) {
        [
          pair.first,
          pair.first |> point.add(diff |> point.scale(idx)),
          pair.first |> point.add(diff |> point.scale(-idx)),
        ]
      })
  }
}
