import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/string
import gleeunit
import gleeunit/should

import graph.{type Graph}

//   /--------------\
//  /                \
// /                 v
// a -----> b -----> d
// \                 ^
//  \                |
//   \----> c -----> e
const example = "a -> b
a -> c
a -> d
b -> d
c -> e
e -> d"

pub fn main() {
  gleeunit.main()
}

pub fn neighbors_test() {
  graph.from_string(example, "->")
  |> assert_neighbors("a", ["b", "c", "d"])
  |> assert_neighbors("b", ["d"])
  |> assert_neighbors("c", ["e"])
  |> assert_neighbors("d", [])
  |> assert_neighbors("e", ["d"])
}

pub fn adjacent_test() {
  graph.from_string(example, "->")
  |> assert_adjacency("a", "b", True)
  |> assert_adjacency("a", "c", True)
  |> assert_adjacency("a", "d", True)
  |> assert_adjacency("a", "e", False)
  |> assert_adjacency("b", "a", False)
  |> assert_adjacency("b", "c", False)
  |> assert_adjacency("b", "d", True)
  |> assert_adjacency("b", "e", False)
  |> assert_adjacency("c", "a", False)
  |> assert_adjacency("c", "b", False)
  |> assert_adjacency("c", "d", False)
  |> assert_adjacency("c", "e", True)
  |> assert_adjacency("d", "a", False)
  |> assert_adjacency("d", "b", False)
  |> assert_adjacency("d", "c", False)
  |> assert_adjacency("d", "e", False)
  |> assert_adjacency("e", "a", False)
  |> assert_adjacency("e", "b", False)
  |> assert_adjacency("e", "c", False)
  |> assert_adjacency("e", "d", True)
}

pub fn weight_test() {
  graph.from_string(example, "->")
  |> assert_weight("a", "b", 1)
  |> assert_weight("a", "c", 1)
  |> assert_weight("a", "d", 1)
  |> assert_weight("a", "e", -1)
  |> assert_weight("b", "a", -1)
  |> assert_weight("b", "c", -1)
  |> assert_weight("b", "d", 1)
  |> assert_weight("b", "e", -1)
  |> assert_weight("c", "a", -1)
  |> assert_weight("c", "b", -1)
  |> assert_weight("c", "d", -1)
  |> assert_weight("c", "e", 1)
  |> assert_weight("d", "a", -1)
  |> assert_weight("d", "b", -1)
  |> assert_weight("d", "c", -1)
  |> assert_weight("d", "e", -1)
  |> assert_weight("e", "a", -1)
  |> assert_weight("e", "b", -1)
  |> assert_weight("e", "c", -1)
  |> assert_weight("e", "d", 1)
}

pub fn add_test() {
  graph.from_string(example, "->")
  |> graph.add("a", "e")
  |> graph.add("e", "a")
  |> graph.add("d", "c")
  |> assert_neighbors("a", ["b", "c", "d", "e"])
  |> assert_neighbors("b", ["d"])
  |> assert_neighbors("c", ["e"])
  |> assert_neighbors("d", ["c"])
  |> assert_neighbors("e", ["d", "a"])
}

fn assert_neighbors(
  gr: Graph(String),
  vertex: String,
  neighbors: List(String),
) -> Graph(String) {
  gr
  |> function.tap(fn(gr) {
    gr
    |> graph.neighbors(vertex)
    |> list.sort(by: string.compare)
    |> should.equal(
      neighbors
      |> list.sort(by: string.compare),
    )
  })
}

fn assert_adjacency(
  gr: Graph(String),
  source: String,
  target: String,
  expected: Bool,
) -> Graph(String) {
  gr
  |> function.tap(fn(gr) {
    gr
    |> graph.adjacent(source, target)
    |> should.equal(expected)
  })
}

fn assert_weight(
  gr: Graph(String),
  source: String,
  target: String,
  expected: Int,
) -> Graph(String) {
  gr
  |> function.tap(fn(gr) {
    gr
    |> graph.weight(source, target)
    |> should.equal(expected)
  })
}
