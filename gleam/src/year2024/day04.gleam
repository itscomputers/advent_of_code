import args.{type Part, PartOne, PartTwo}
import gleam/bool
import gleam/int
import gleam/list

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
    { gr |> get_chars(pt, dir, list.range(0, 3)) == ["X", "M", "A", "S"] }
    |> bool.to_int
  })
  |> int.sum
}

fn x_mas(gr: Grid, pt: Point) -> Int {
  [Point(1, 1), Point(1, -1)]
  |> list.all(fn(direction) {
    [direction, direction |> point.negate]
    |> list.any(fn(dir) {
      gr |> get_chars(pt, dir, list.range(-1, 1)) == ["M", "A", "S"]
    })
  })
  |> bool.to_int
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
