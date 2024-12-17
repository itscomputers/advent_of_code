import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/order.{Eq, Gt, Lt}

import point.{type Point, Point}

pub type Direction {
  Right
  Down
  Left
  Up
}

pub fn all() -> List(Direction) {
  [Right, Down, Left, Up]
}

pub fn to_point(dir: Direction) -> Point {
  case dir {
    Right -> Point(1, 0)
    Down -> Point(0, 1)
    Left -> Point(-1, 0)
    Up -> Point(0, -1)
  }
}

pub fn from_point_unsafe(pt: Point) -> Direction {
  let assert Some(dir) = from_point(pt)
  dir
}

pub fn from_point(pt: Point) -> Option(Direction) {
  case pt.x |> int.compare(0), pt.y |> int.compare(0) {
    Gt, Eq -> Right |> Some
    Lt, Eq -> Left |> Some
    Eq, Gt -> Down |> Some
    Eq, Lt -> Up |> Some
    _, _ -> None
  }
}

pub fn rotate(dir: Direction, rotation: point.Rotation) -> Direction {
  dir |> to_point |> point.rotate(rotation) |> from_point_unsafe
}

pub fn cw(dir: Direction) -> Direction {
  dir |> rotate(point.CW)
}

pub fn ccw(dir: Direction) -> Direction {
  dir |> rotate(point.CCW)
}

pub fn opp(dir: Direction) -> Direction {
  dir |> to_point |> point.negate |> from_point_unsafe
}

pub fn step(pt: Point, dir: Direction) -> Point {
  move(pt, dir, 1)
}

pub fn move(pt: Point, dir: Direction, times count: Int) -> Point {
  pt |> point.add(dir |> to_point |> point.scale(count))
}

pub fn is_horizontal(dir: Direction) -> Bool {
  case dir {
    Right | Left -> True
    Up | Down -> False
  }
}

pub fn is_vertical(dir: Direction) -> Bool {
  !is_horizontal(dir)
}
