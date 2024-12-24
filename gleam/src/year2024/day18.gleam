import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import gleam/string
import regex

import graph/graph.{type Graph}
import graph/search
import point.{type Point, Point}
import range.{Range}
import util

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> part_one(1024, 71) |> int.to_string
    PartTwo -> input |> part_two(1024, 71)
  }
}

pub fn part_one(input: String, byte_count: Int, size: Int) -> Int {
  input
  |> points
  |> list.take(byte_count)
  |> distance(size)
}

pub fn part_two(input: String, byte_count: Int, size: Int) -> String {
  let pts = input |> points
  let path = pts |> list.take(byte_count) |> path_pts(size)
  pts
  |> loop_two(path, byte_count, size)
  |> fn(pt) {
    pt |> point.coords |> list.map(int.to_string) |> string.join(",")
  }
}

fn loop_two(
  points: List(Point),
  path: Set(Point),
  index: Int,
  size: Int,
) -> Point {
  case index == points |> list.length {
    True -> panic
    False -> {
      let pts = points |> list.take(index)
      let assert Ok(pt) = pts |> list.last
      case path |> set.contains(pt) {
        False -> loop_two(points, path, index + 1, size)
        True -> {
          let path = pts |> path_pts(size)
          case path |> set.size {
            0 -> pt
            _ -> loop_two(points, path, index + 1, size)
          }
        }
      }
    }
  }
}

fn points(input: String) -> List(Point) {
  input
  |> util.lines
  |> list.map(regex.int_matches)
  |> list.map(fn(ints) {
    let assert [x, y] = ints
    Point(x, y)
  })
}

fn graph(points: List(Point), size: Int) -> Graph(Point) {
  let point_set = set.from_list(points)
  Range(0, size)
  |> range.fold(from: graph.new(), with: fn(acc, y) {
    Range(0, size)
    |> range.fold(from: acc, with: fn(acc, x) {
      let pt = Point(x, y)
      case point_set |> set.contains(pt) {
        True -> acc
        False ->
          pt
          |> point.strict_neighbors
          |> list.fold(from: acc, with: fn(acc, neighbor) {
            acc |> graph.add(pt, neighbor)
          })
      }
    })
  })
}

fn distance(pts: List(Point), size: Int) -> Int {
  pts |> path_pts(size) |> set.size |> int.subtract(1)
}

fn path_pts(pts: List(Point), size: Int) -> Set(Point) {
  case
    pts
    |> graph(size)
    |> search.path(
      from: Point(0, 0),
      to: Point(size - 1, size - 1),
      using: search.BFS,
    )
  {
    Some(path) -> path |> set.from_list
    None -> set.new()
  }
}
