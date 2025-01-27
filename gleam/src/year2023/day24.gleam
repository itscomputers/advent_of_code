import gleam/float
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string

import args.{type Part, PartOne, PartTwo}
import point.{type Point, Point}
import range.{type Range, Range}
import regex
import util

pub type HailStone {
  HailStone(pos: Point3d, vel: Point3d)
}

pub type Point3d {
  Point3d(x: Int, y: Int, z: Int)
}

type Coord {
  X
  Y
  Z
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> hailstones
      |> intersection_count(Range(200_000_000_000_000, 400_000_000_000_000))
      |> int.to_string
    PartTwo ->
      input
      |> hailstones
      |> find_rock_pos(Range(-10_000, 10_000))
      |> coords
      |> int.sum
      |> int.to_string
  }
}

pub fn hailstones(input: String) -> List(HailStone) {
  input
  |> util.lines
  |> list.map(fn(line) {
    let assert [p_str, v_str] = line |> string.split(" @ ")
    let assert [px, py, pz] = p_str |> regex.int_matches
    let assert [vx, vy, vz] = v_str |> regex.int_matches
    HailStone(Point3d(px, py, pz), Point3d(vx, vy, vz))
  })
}

fn intersects_in_range(h0: HailStone, h1: HailStone, range: Range) -> Bool {
  case intersection(h0, h1) {
    Some(pt) -> pt |> point.coords |> list.all(range.contains(range, _))
    None -> False
  }
}

pub fn intersection_count(hailstones: List(HailStone), range: Range) -> Int {
  hailstones
  |> list.combination_pairs
  |> list.count(fn(p) { intersects_in_range(p.0, p.1, range) })
}

fn intersection(h0: HailStone, h1: HailStone) -> Option(Point) {
  let #(s, t) = parameters(h0, h1)
  case s <=. 0.0 || t <=. 0.0 {
    True -> None
    False -> {
      let x = int.to_float(h0.pos.x) +. int.to_float(h0.vel.x) *. s
      let y = int.to_float(h0.pos.y) +. int.to_float(h0.vel.y) *. s
      Point(x |> float.floor |> float.round, y |> float.floor |> float.round)
      |> Some
    }
  }
}

fn parameters(h0: HailStone, h1: HailStone) -> #(Float, Float) {
  let p0 = h0.pos
  let p1 = h1.pos
  let v0 = h0.vel
  let v1 = h1.vel
  let d = determinant(v0, v1) |> int.to_float
  let col = Point(p1.x - p0.x, p1.y - p0.y)
  case d == 0.0 {
    True -> #(d, d)
    False -> #(
      { Point(-v1.y, v1.x) |> point.dot(col) |> int.to_float } /. d,
      { Point(-v0.y, v0.x) |> point.dot(col) |> int.to_float } /. d,
    )
  }
}

fn determinant(v0: Point3d, v1: Point3d) -> Int {
  v1.x * v0.y - v0.x * v1.y
}

fn pos(hs: HailStone, coord: Coord) -> Int {
  case coord {
    X -> hs.pos.x
    Y -> hs.pos.y
    Z -> hs.pos.z
  }
}

fn vel(hs: HailStone, coord: Coord) -> Int {
  case coord {
    X -> hs.vel.x
    Y -> hs.vel.y
    Z -> hs.vel.z
  }
}

fn coords(pt: Point3d) -> List(Int) {
  [pt.x, pt.y, pt.z]
}

fn find_rock_pos(hailstones: List(HailStone), range: Range) -> Point3d {
  let assert [h0, h1, ..] = hailstones
  let vx = rock_vel(hailstones, X, range)
  let vy = rock_vel(hailstones, Y, range)
  let vz = rock_vel(hailstones, Z, range)
  let v = Point(vx, vy)
  let assert Some(Point(px, py)) =
    intersection(slow(h0, by: v), slow(h1, by: v))
  let t = { px - pos(h0, X) } / { vel(h0, X) - vx }
  let pz = pos(h0, Z) + { vel(h0, Z) - vz } * t
  Point3d(px, py, pz)
}

fn slow(hs: HailStone, by vel: Point) -> HailStone {
  let vel = Point3d(..hs.vel, x: hs.vel.x - vel.x, y: hs.vel.y - vel.y)
  HailStone(..hs, vel:)
}

fn rock_vel(hailstones: List(HailStone), coord: Coord, range: Range) -> Int {
  case
    hailstones
    |> list.combination_pairs
    |> list.filter(fn(p) { vel(p.0, coord) == vel(p.1, coord) })
    |> list.fold(from: set.new(), with: fn(acc, p) {
      case acc |> set.size {
        1 -> acc
        _ -> {
          let vels = possible_velocities(p.0, p.1, coord, range)
          case acc |> set.is_empty {
            True -> vels
            False -> acc |> set.intersection(vels)
          }
        }
      }
    })
    |> set.to_list
  {
    [vel] -> vel
    _ -> panic
  }
}

fn possible_velocities(
  h0: HailStone,
  h1: HailStone,
  coord: Coord,
  range: Range,
) -> Set(Int) {
  let velocity = h0 |> vel(coord)
  let distance = pos(h1, coord) - pos(h0, coord)
  range
  |> range.fold(from: set.new(), with: fn(acc, vel) {
    case vel != velocity, distance % int.absolute_value(vel - velocity) {
      True, 0 -> acc |> set.insert(vel)
      _, _ -> acc
    }
  })
}
