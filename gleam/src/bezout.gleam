import gleam/float
import gleam/int
import gleam/list
import gleam/order.{Eq, Gt, Lt}

import point.{type Point, Horizontal, Point}
import range.{type Range, Range}

pub opaque type Bezout {
  Bezout(a: Int, b: Int, gcd: Int, solution: fn(Int) -> Point)
}

pub fn new(a: Int, b: Int) -> Bezout {
  let Point(x, y) = bezout(a, b)
  let d = gcd(a, b)
  Bezout(a, b, d, fn(t) { Point(x - { b / d } * t, y + { a / d } * t) })
}

pub fn solution(bezout: Bezout, t: Int) -> Point {
  bezout.solution(t)
}

pub fn unsafe_scaled_solution(bezout: Bezout, target: Int, t: Int) -> Point {
  bezout |> scale_unsafe(by: target) |> solution(t)
}

fn scale_unsafe(bezout: Bezout, by target: Int) -> Bezout {
  Bezout(
    ..bezout,
    solution: fn(t) {
      bezout.solution(0)
      |> point.scale(target)
      |> point.add(
        Point(-bezout.b / bezout.gcd, bezout.a / bezout.gcd)
        |> point.scale(t),
      )
    },
  )
}

pub fn positive_solutions(bezout: Bezout, target: Int) -> List(Point) {
  bezout
  |> positive_range(target)
  |> range.values
  |> list.map(unsafe_scaled_solution(bezout, target, _))
}

pub fn positive_range(bezout: Bezout, target: Int) -> Range {
  case target % bezout.gcd {
    0 -> {
      let bezout = bezout |> scale_unsafe(by: target)
      let m = bezout.b / bezout.gcd
      let n = bezout.a / bezout.gcd
      let Point(x, y) = bezout.solution(0)
      let lower = ceil_div(-y, n)
      let upper = floor_div(x, m)
      Range(lower, upper + 1)
    }
    _ -> range.empty()
  }
}

pub fn solutions(
  bezout: Bezout,
  target: Int,
  x_range: Range,
  y_range: Range,
) -> List(Point) {
  case target % bezout.gcd {
    0 -> {
      let bezout = bezout |> scale_unsafe(by: target)
      let m = bezout.b / bezout.gcd
      let n = bezout.a / bezout.gcd
      let Point(x, y) = bezout.solution(0)
      let lower =
        int.max(
          ceil_div(x - x_range.upper - 1, m),
          ceil_div(y_range.lower - y, n),
        )
      let upper =
        int.min(
          ceil_div(x - x_range.lower, m),
          ceil_div(y_range.upper - 1 - y, n),
        )
      list.range(lower, upper) |> list.map(bezout.solution)
    }
    _ -> []
  }
}

fn gcd(number: Int, with other: Int) -> Int {
  case other {
    0 -> number |> int.absolute_value
    _ -> gcd(other, number % other)
  }
}

fn bezout(number: Int, other: Int) -> Point {
  case sgn(number), sgn(other) {
    0, s -> Point(0, s)
    s, 0 -> Point(s, 0)
    _, -1 ->
      bezout(number, other |> int.absolute_value)
      |> point.reflect(across: Horizontal)
    _, _ -> loop(number, other, Point(1, 0), Point(0, 1))
  }
}

fn loop(number: Int, other: Int, prev: Point, curr: Point) -> Point {
  case other |> int.compare(0) {
    Eq -> prev
    Lt -> panic
    Gt -> {
      let #(quo, rem) = div_mod(number, other)
      let next = prev |> point.subtract(curr |> point.scale(quo))
      loop(other, rem, curr, next)
    }
  }
}

fn sgn(value: Int) -> Int {
  value |> int.compare(0) |> order.to_int
}

fn mod(number: Int, by divisor: Int) -> Int {
  let remainder = number % divisor
  case remainder |> int.compare(0) {
    Lt -> divisor |> int.absolute_value |> int.add(remainder)
    _ -> remainder
  }
}

fn div_mod(number: Int, by divisor: Int) -> #(Int, Int) {
  number
  |> mod(divisor)
  |> fn(remainder) { #({ number - remainder } / divisor, remainder) }
}

fn floor_div(a: Int, b: Int) -> Int {
  { int.to_float(a) /. int.to_float(b) } |> float.floor |> float.round
}

fn ceil_div(a: Int, b: Int) -> Int {
  { int.to_float(a) /. int.to_float(b) } |> float.ceiling |> float.round
}
