import gleam/dict.{type Dict}
import gleam/list
import gleam/string

import point.{type Point, Point}

pub fn parse(str: String) -> Dict(Point, String) {
  str
  |> string.split("\n")
  |> list.index_map(fn(line, row) {
    line
    |> string.to_graphemes
    |> list.index_map(fn(char, col) { #(Point(col, row), char) })
  })
  |> list.flatten
  |> dict.from_list
}
