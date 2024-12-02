import gleam/int
import gleam/list

pub type Rotation {
  CW
  CCW
  CWAround(center: Point)
  CCWAround(center: Point)
}

pub type Point {
  Point(x: Int, y: Int)
}

pub fn add(point: Point, other: Point) -> Point {
  Point(point.x + other.x, point.y + other.y)
}

pub fn subtract(point: Point, other: Point) -> Point {
  point |> add(other |> negate)
}

pub fn negate(point: Point) -> Point {
  point |> map(int.negate)
}

pub fn scale(point: Point, by scalar: Int) -> Point {
  point |> map(int.multiply(_, scalar))
}

pub fn norm(point: Point) -> Int {
  point |> coords |> list.map(int.absolute_value) |> int.sum
}

pub fn distance(point: Point, other: Point) -> Int {
  point |> subtract(other) |> norm
}

pub fn map(point: Point, func: fn(Int) -> Int) -> Point {
  Point(func(point.x), func(point.y))
}

pub fn rotate(point: Point, rotation: Rotation) -> Point {
  case rotation {
    CW -> Point(-point.y, point.x)
    CCW -> Point(point.y, -point.x)
    CWAround(center) -> center |> subtract(point) |> rotate(CW) |> add(center)
    CCWAround(center) -> center |> subtract(point) |> rotate(CCW) |> add(center)
  }
}

pub fn neighbors(point: Point) -> List(Point) {
  list.append(point |> strict_neighbors, point |> diagonal_neighbors)
}

pub fn strict_neighbors(point: Point) -> List(Point) {
  point
  |> get_neighbors([Point(-1, 0), Point(0, -1), Point(0, 1), Point(1, 0)])
}

pub fn diagonal_neighbors(point: Point) -> List(Point) {
  point
  |> get_neighbors([Point(-1, -1), Point(-1, 1), Point(1, -1), Point(1, 1)])
}

fn get_neighbors(point: Point, directions: List(Point)) {
  directions
  |> list.map(add(_, point))
}

fn coords(point: Point) -> List(Int) {
  [point.x, point.y]
}
