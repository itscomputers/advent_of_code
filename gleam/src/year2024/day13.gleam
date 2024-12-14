import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/option.{None, Some}

import matrix
import point.{type Point, Point}
import regex
import util

type Claw {
  Claw(a: Point, b: Point, prize: Point)
}

pub fn main(input: String, part: Part) -> String {
  input |> claws(part) |> token_count |> int.to_string
}

fn claws(input: String, part: Part) -> List(Claw) {
  input |> util.blocks |> list.map(claw(_, part))
}

fn claw(block: String, part: Part) -> Claw {
  case block |> util.lines {
    [l1, l2, l3] -> {
      let assert [ax, ay] = l1 |> regex.int_matches
      let assert [bx, by] = l2 |> regex.int_matches
      let assert [px, py] = l3 |> regex.int_matches
      let a = Point(ax, ay)
      let b = Point(bx, by)
      let prize = case part {
        PartOne -> Point(px, py)
        PartTwo ->
          Point(px, py)
          |> point.add(Point(10_000_000_000_000, 10_000_000_000_000))
      }
      Claw(a:, b:, prize:)
    }
    _ -> panic
  }
}

fn token_count(claws: List(Claw)) -> Int {
  claws |> list.map(tokens) |> int.sum
}

fn tokens(claw: Claw) -> Int {
  case matrix.from_cols(claw.a, claw.b) |> matrix.solution(claw.prize) {
    None -> 0
    Some(pt) -> pt |> point.dot(Point(3, 1))
  }
}
