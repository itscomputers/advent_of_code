import args.{type Part, PartOne, PartTwo}
import gleam/bool
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/set.{type Set}

import direction.{type Direction, Down, Left, Right, Up} as dir
import grid
import point.{type Point, Point}
import range.{type Range, Range}

type Region {
  Region(id: String, points: Set(Point))
  SubRegion(
    id: String,
    points: Set(Point),
    interior_count: Int,
    dimensions: #(Range, Range),
  )
}

type Garden {
  Garden(regions: Dict(String, Region))
}

pub fn main(input: String, part: Part) -> String {
  input |> garden |> total_price(part) |> int.to_string
}

fn garden(input: String) -> Garden {
  input
  |> grid.new
  |> grid.fold(from: Garden(dict.new()), with: add_point)
}

fn add_point(garden: Garden, pt: Point, id: String) -> Garden {
  let points = case garden.regions |> dict.get(id) {
    Ok(region) -> region.points |> set.insert(pt)
    Error(_) -> set.from_list([pt])
  }
  let region = Region(id:, points:)
  Garden(regions: garden.regions |> dict.insert(id, region))
}

fn price(region: Region, part: Part) -> Int {
  case region, part {
    Region(..), _ ->
      region
      |> subregions
      |> list.map(price(_, part))
      |> int.sum
    _, PartOne -> area(region) * perim(region)
    _, PartTwo -> area(region) * edges(region)
  }
}

fn total_price(garden: Garden, part: Part) -> Int {
  garden.regions
  |> dict.map_values(fn(_, region) { price(region, part) })
  |> dict.values
  |> int.sum
}

fn area(subregion: Region) -> Int {
  set.size(subregion.points)
}

fn perim(subregion: Region) -> Int {
  case subregion {
    Region(..) -> panic
    SubRegion(_, _, count, _) -> 4 * area(subregion) - 2 * count
  }
}

fn subregions(region: Region) -> List(Region) {
  subregions_loop(region, [], region.points)
}

fn subregions_loop(
  region: Region,
  subregions: List(Region),
  unvisited: Set(Point),
) -> List(Region) {
  case unvisited |> set.to_list {
    [] -> subregions
    [pt, ..] -> {
      let sub = region |> subregion(of: pt)
      subregions_loop(
        region,
        [sub, ..subregions],
        unvisited |> set.difference(sub.points),
      )
    }
  }
}

fn subregion(region: Region, of pt: Point) -> Region {
  subregion_loop(
    region,
    SubRegion(
      id: region.id,
      points: set.new(),
      interior_count: 0,
      dimensions: #(range.empty(), range.empty()),
    ),
    [pt],
  )
}

fn subregion_loop(
  region: Region,
  subregion: Region,
  queue: List(Point),
) -> Region {
  case queue {
    [] -> subregion
    [pt, ..queue] -> {
      case subregion.points |> set.contains(pt) {
        True -> subregion_loop(region, subregion, queue)
        False ->
          case subregion {
            Region(..) -> panic
            SubRegion(_, points, interior_count, #(x_range, y_range)) -> {
              let unvisited =
                pt
                |> point.strict_neighbors
                |> list.filter(fn(neighbor) {
                  set.contains(region.points, neighbor)
                  && !set.contains(points, neighbor)
                })
              let dimensions = #(
                x_range |> expand(with: pt.x),
                y_range |> expand(with: pt.y),
              )
              let interior_count = interior_count + list.length(unvisited)
              let points = subregion.points |> set.insert(pt)
              let subregion =
                SubRegion(
                  id: subregion.id,
                  points:,
                  interior_count:,
                  dimensions:,
                )
              subregion_loop(region, subregion, list.append(queue, unvisited))
            }
          }
      }
    }
  }
}

fn expand(range: Range, with value: Int) -> Range {
  case range |> range.is_empty {
    True -> Range(value, value + 1)
    False ->
      case value < range.lower {
        True -> Range(..range, lower: value)
        False ->
          case value >= range.upper {
            True -> Range(..range, upper: value + 1)
            False -> range
          }
      }
  }
}

fn edges(subregion: Region) -> Int {
  case subregion {
    Region(..) -> panic
    SubRegion(..) ->
      [Left, Right, Up, Down]
      |> list.map(get_edge_counts(subregion, _))
      |> int.sum
  }
}

fn get_edge_counts(subregion: Region, direction: Direction) -> Int {
  case subregion, direction |> dir.is_horizontal {
    Region(..), _ -> panic
    SubRegion(_, _, _, #(x_range, _)), True ->
      x_range
      |> range.values
      |> list.map(get_edge_count(subregion, _, direction))
      |> int.sum
    SubRegion(_, _, _, #(_, y_range)), False ->
      y_range
      |> range.values
      |> list.map(get_edge_count(subregion, _, direction))
      |> int.sum
  }
}

fn get_edge_count(subregion: Region, value: Int, direction: Direction) -> Int {
  case subregion {
    Region(..) -> panic
    SubRegion(_, points, _, dimensions) -> {
      dimensions
      |> get_range(direction)
      |> range.values
      |> list.map(get_point(value, _, direction))
      |> list.filter(fn(pt) {
        set.contains(points, pt)
        && !set.contains(points, pt |> dir.step(direction))
      })
      |> with_padding(direction)
      |> list.map(get_value(_, direction))
      |> list.window_by_2
      |> list.map(fn(tuple) { tuple.1 - tuple.0 != 1 })
      |> list.map(bool.to_int)
      |> int.sum
    }
  }
}

fn get_range(dimensions: #(Range, Range), direction: Direction) -> Range {
  case direction |> dir.is_horizontal {
    True -> dimensions.1
    False -> dimensions.0
  }
}

fn get_point(value: Int, other: Int, direction: Direction) -> Point {
  case direction |> dir.is_horizontal {
    True -> Point(value, other)
    False -> Point(other, value)
  }
}

fn with_padding(points: List(Point), direction: Direction) -> List(Point) {
  case points {
    [] -> []
    [first, ..] -> {
      let direction = case direction |> dir.is_horizontal {
        True -> Up
        False -> Left
      }
      [first |> dir.move(direction, times: 2), ..points]
    }
  }
}

fn get_value(pt: Point, direction: Direction) -> Int {
  case direction |> dir.is_horizontal {
    True -> pt.y
    False -> pt.x
  }
}
