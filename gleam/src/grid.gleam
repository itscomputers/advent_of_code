import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import gleam/string_tree

import point.{type Point, Point}
import range.{type Range, Range}

pub opaque type Grid {
  Grid(lookup: Dict(Point, String), x_range: Range, y_range: Range)
}

pub fn new(str: String) -> Grid {
  str
  |> string.split("\n")
  |> list.index_map(fn(line, row) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, col) { #(Point(col, row), char) })
  })
  |> list.flatten
  |> dict.from_list
  |> Grid(build_x_range(str), build_y_range(str))
}

pub fn dimensions(grid: Grid) -> Point {
  Point(range.size(grid.x_range), range.size(grid.y_range))
}

pub fn get(grid: Grid, point: Point) -> Option(String) {
  grid.lookup |> dict.get(point) |> option.from_result
}

pub fn get_or(grid: Grid, point: Point, default default: String) -> String {
  case grid |> get(point) {
    Some(char) -> char
    None -> default
  }
}

pub fn reverse_lookup(grid: Grid) -> Dict(String, List(Point)) {
  grid
  |> fold(from: dict.new(), with: fn(acc, point, ch) {
    acc
    |> dict.upsert(update: ch, with: fn(opt) {
      case opt {
        Some(points) -> [point, ..points]
        None -> [point]
      }
    })
  })
}

pub fn set(grid: Grid, point: Point, value: String) -> Grid {
  Grid(..grid, lookup: grid.lookup |> dict.insert(point, value))
}

pub fn fold(
  grid: Grid,
  from initial: a,
  with func: fn(a, Point, String) -> a,
) -> a {
  grid.lookup |> dict.fold(from: initial, with: func)
}

pub fn sub(grid: Grid, func: fn(String) -> String) -> Grid {
  Grid(
    ..grid,
    lookup: grid.lookup |> dict.map_values(fn(_, value) { func(value) }),
  )
}

pub fn to_string(grid: Grid, default default: String) -> String {
  grid
  |> matrix(default: default)
  |> list.map(string_tree.from_strings)
  |> string_tree.join("\n")
  |> string_tree.to_string
}

pub fn matrix(grid: Grid, default default: String) -> List(List(String)) {
  grid.y_range
  |> range.values
  |> list.map(fn(y) {
    grid.x_range
    |> range.values
    |> list.map(fn(x) { grid |> get_or(Point(x, y), default) })
  })
}

pub fn filter(grid: Grid, select predicate: fn(String) -> Bool) -> List(Point) {
  grid.lookup
  |> dict.filter(fn(_, value) { predicate(value) })
  |> dict.keys
}

pub fn display(grid: Grid) -> Grid {
  io.println("")
  grid.y_range
  |> range.map(fn(y) {
    grid.x_range
    |> range.fold(from: string_tree.new(), with: fn(acc, x) {
      acc |> string_tree.append(grid |> get_or(Point(x, y), default: "."))
    })
    |> string_tree.to_string
    |> io.println
  })
  grid
}

fn build_x_range(str: String) -> Range {
  case str |> string.split("\n") {
    [line, ..] -> Range(0, line |> string.length)
    _ -> range.empty()
  }
}

fn build_y_range(str: String) -> Range {
  Range(0, str |> string.split("\n") |> list.length)
}
