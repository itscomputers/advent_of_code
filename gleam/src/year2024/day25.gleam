import args.{type Part, PartOne, PartTwo}
import gleam/function
import gleam/int
import gleam/list

import grid
import util

type Schematic {
  Schematic(keys: List(List(Int)), locks: List(List(Int)))
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> build_schematic |> key_count |> int.to_string
    PartTwo -> "the end"
  }
}

fn key_count(schematic: Schematic) -> Int {
  schematic.keys
  |> list.map(fn(key) {
    schematic.locks
    |> list.count(fn(lock) {
      key
      |> list.zip(lock)
      |> list.all(fn(t) { t.0 + t.1 < 6 })
    })
  })
  |> int.sum
}

fn build_schematic(input: String) -> Schematic {
  input
  |> util.blocks
  |> list.fold(from: Schematic(keys: [], locks: []), with: process_block)
}

fn process_block(schematic: Schematic, block: String) -> Schematic {
  case block |> is_lock {
    True -> Schematic(..schematic, locks: [lock(block), ..schematic.locks])
    False -> Schematic(..schematic, keys: [key(block), ..schematic.keys])
  }
}

fn is_lock(block: String) -> Bool {
  block |> util.lines |> list.first == Ok("#####")
}

fn lock(block: String) -> List(Int) {
  build(block, list.last, function.identity)
}

fn key(block: String) -> List(Int) {
  build(block, list.first, fn(y) { 6 - y })
}

fn build(
  block: String,
  func: fn(List(Int)) -> Result(Int, Nil),
  transform: fn(Int) -> Int,
) {
  let points =
    block
    |> grid.new
    |> grid.filter(fn(ch) { ch == "#" })
  list.range(0, 4)
  |> list.map(fn(x) {
    case
      points
      |> list.filter(fn(pt) { pt.x == x })
      |> list.map(fn(pt) { pt.y })
      |> func
    {
      Ok(value) -> value |> transform
      Error(_) -> panic
    }
  })
}
