import gleam/dict
import gleam/function
import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{Gt, Lt}
import gleam/set.{type Set}
import gleam/string
import gleam/string_tree

import args.{type Part, PartOne, PartTwo}
import counter.{type Counter}
import point.{type Point, Point}
import range.{type Range, Range}
import regex
import util

const dimensions = Point(101, 103)

type Robot {
  Robot(pos: Point, vel: Point)
}

type Bathroom {
  Bathroom(robots: List(Robot), dimensions: Point)
}

type Quadrant {
  I
  II
  III
  IV
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> safety_factor(dimensions) |> int.to_string
    PartTwo -> input |> bathroom(dimensions) |> xmas_tree |> int.to_string
  }
}

fn bathroom(input: String, dimensions: Point) -> Bathroom {
  Bathroom(robots: input |> robots, dimensions:)
}

pub fn safety_factor(input: String, dimensions: Point) -> Int {
  input
  |> bathroom(dimensions)
  |> wait(for: 100)
  |> quadrants
  |> counter.fold(from: 1, with: fn(acc, _quadrant, count) { acc * count })
}

fn quadrants(bathroom: Bathroom) -> Counter(Quadrant) {
  bathroom.robots
  |> list.fold(from: counter.new(), with: fn(acc, robot) {
    case bathroom |> quadrant(of: robot) {
      Some(quadrant) -> acc |> counter.increment(quadrant, by: 1)
      None -> acc
    }
  })
}

fn quadrant(bathroom: Bathroom, of robot: Robot) -> Option(Quadrant) {
  case
    int.compare(robot.pos.x, bathroom.dimensions.x / 2),
    int.compare(robot.pos.y, bathroom.dimensions.y / 2)
  {
    Lt, Lt -> Some(I)
    Gt, Lt -> Some(II)
    Lt, Gt -> Some(III)
    Gt, Gt -> Some(IV)
    _, _ -> None
  }
}

fn robots(input: String) -> List(Robot) {
  input |> util.lines |> list.map(build_robot)
}

fn build_robot(line: String) -> Robot {
  case line |> string.split(" ") |> list.map(regex.int_matches) {
    [[x, y], [vx, vy]] -> Robot(pos: Point(x, y), vel: Point(vx, vy))
    _ -> panic
  }
}

fn wait(bathroom: Bathroom, for seconds: Int) -> Bathroom {
  let robots = bathroom.robots |> list.map(move(bathroom, _, seconds))
  Bathroom(..bathroom, robots:)
}

fn move(bathroom: Bathroom, robot: Robot, times count: Int) -> Robot {
  Robot(
    ..robot,
    pos: robot.pos
      |> point.add(robot.vel |> point.scale(count))
      |> point.reduce(mod: bathroom.dimensions),
  )
}

fn points(bathroom: Bathroom) -> Set(Point) {
  bathroom.robots
  |> list.map(fn(robot) { robot.pos })
  |> set.from_list
}

fn xmas_tree(bathroom: Bathroom) {
  let border =
    list.range(50, 79)
    |> list.map(fn(x) { Point(x, 44) })
    |> set.from_list
  xmas_loop(bathroom, border, 0)
}

fn xmas_loop(bathroom: Bathroom, border: Set(Point), index: Int) -> Int {
  case bathroom |> points |> set.intersection(border) == border {
    True -> index
    False -> xmas_loop(bathroom |> wait(1), border, index + 1)
  }
}

fn display_loop(bathroom: Bathroom, count: Int, max: Int) -> Bathroom {
  case max - count {
    0 -> bathroom
    _ -> bathroom |> wait(1) |> display(count) |> display_loop(count + 1, max)
  }
}

fn display(bathroom: Bathroom, index: Int) -> Bathroom {
  let d =
    bathroom.robots
    |> list.map(fn(robot) { #(robot.pos, "#") })
    |> dict.from_list
  case
    list.range(0, 70)
    |> list.any(fn(y) {
      list.range(0, 70)
      |> list.any(fn(x) {
        list.range(x, x + 29)
        |> list.all(fn(x) { dict.get(d, Point(x, y)) == Ok("#") })
        |> function.tap(fn(bool) {
          case bool {
            True -> {
              io.println(
                "x, y = ("
                <> int.to_string(x)
                <> ", "
                <> int.to_string(y)
                <> ")",
              )
            }
            False -> Nil
          }
        })
      })
    })
  {
    True -> {
      io.println("")
      io.println("index: " <> int.to_string(index))
      Range(0, bathroom.dimensions.y)
      |> range.map(fn(y) {
        Range(0, bathroom.dimensions.x)
        |> range.fold(from: string_tree.new(), with: fn(acc, x) {
          case d |> dict.get(Point(x, y)) {
            Ok(ch) -> acc |> string_tree.append(ch)
            Error(_) -> acc |> string_tree.append(".")
          }
        })
        |> string_tree.to_string
        |> io.println
      })
      bathroom
    }
    _ -> bathroom
  }
}
