import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/string

import args.{type Part, PartOne, PartTwo}
import regex
import util

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> games
      |> list.filter(is_possible(_, CubeSet(12, 13, 14)))
      |> list.map(fn(game) { game.id })
      |> int.sum
      |> int.to_string
    PartTwo ->
      input
      |> games
      |> list.map(min_required)
      |> list.map(power)
      |> int.sum
      |> int.to_string
  }
}

type Game {
  Game(id: Int, sets: List(CubeSet))
}

type CubeSet {
  CubeSet(red: Int, green: Int, blue: Int)
}

fn games(input: String) -> List(Game) {
  input |> util.lines |> list.map(build_game)
}

fn is_possible(game: Game, max_set: CubeSet) -> Bool {
  game.sets |> list.all(fn(set) { max(set, max_set) == max_set })
}

fn power(set: CubeSet) -> Int {
  set.red * set.green * set.blue
}

fn min_required(game: Game) -> CubeSet {
  game.sets |> list.fold(CubeSet(0, 0, 0), max)
}

fn max(set: CubeSet, other: CubeSet) -> CubeSet {
  CubeSet(
    red: int.max(set.red, other.red),
    green: int.max(set.green, other.green),
    blue: int.max(set.blue, other.blue),
  )
}

fn get_game_id(str: String) -> Int {
  case regex.int_submatch(str, "Game (\\d+)") {
    Some(id) -> id
    None -> panic
  }
}

fn build_game(line: String) -> Game {
  case line |> string.split(": ") {
    [game, sets] -> Game(id: get_game_id(game), sets: build_sets(sets))
    _ -> {
      util.debug(line, "invalid line")
      panic
    }
  }
}

fn build_sets(str: String) -> List(CubeSet) {
  str |> string.split("; ") |> list.map(build_set)
}

fn build_set(str: String) -> CubeSet {
  CubeSet(
    red: str |> get_count("red"),
    green: str |> get_count("green"),
    blue: str |> get_count("blue"),
  )
}

fn get_count(str: String, color: String) -> Int {
  case regex.int_submatch(str, "(\\d+) " <> color) {
    Some(count) -> count
    None -> 0
  }
}
