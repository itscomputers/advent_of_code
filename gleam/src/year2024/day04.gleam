import gleam/int
import gleam/list

import args.{type Part, PartOne, PartTwo}
import grid.{type Grid}
import point.{type Point, Point}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> grid
      |> count(xmas)
      |> int.to_string
    PartTwo ->
      input
      |> grid
      |> count(x_mas)
      |> int.to_string
  }
}

fn grid(input: String) -> Grid {
  input |> grid.new
}

fn count(gr: Grid, count_at: fn(Grid, Point) -> Int) -> Int {
  gr |> grid.fold(from: 0, with: fn(acc, pt, _) { acc + count_at(gr, pt) })
}

fn xmas(gr: Grid, pt: Point) -> Int {
  point.directions()
  |> list.map(fn(dir) {
    case get_chars(gr, pt, dir, list.range(0, 3)) == ["X", "M", "A", "S"] {
      True -> 1
      False -> 0
    }
  })
  |> int.sum
}

fn x_mas(gr: Grid, pt: Point) -> Int {
  case
    [Point(1, 1), Point(1, -1)]
    |> list.all(fn(direction) {
      [direction, direction |> point.negate]
      |> list.any(fn(dir) {
        gr |> get_chars(pt, dir, list.range(-1, 1)) == ["M", "A", "S"]
      })
    })
  {
    True -> 1
    False -> 0
  }
}

fn get_chars(
  gr: Grid,
  pt: Point,
  direction: Point,
  scalars: List(Int),
) -> List(String) {
  scalars
  |> list.map(fn(scalar) {
    pt
    |> point.add(direction |> point.scale(scalar))
    |> grid.get_or(gr, _, default: ".")
  })
}
