import gleam/dict
import gleeunit
import gleeunit/should

import graph/graph
import graph/search.{BFS}

// a -----> b -----> d -----> f
// \                 ^
//  \                |
//   \               v
//    \---> c -----> e <----- g
const example = "a -> b
a -> c
d -> f
b -> d
c -> e
d -> e
g -> e
e -> d"

pub fn main() {
  gleeunit.main()
}

pub fn distances_test() {
  example
  |> graph.from_string(" -> ")
  |> search.distances(from: "a", using: BFS)
  |> should.equal(
    [#("a", 0), #("b", 1), #("c", 1), #("d", 2), #("e", 2), #("f", 3)]
    |> dict.from_list,
  )
}

pub fn path_to_a_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "a", using: BFS)
  |> should.be_some
  |> should.equal(["a"])
}

pub fn path_to_b_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "b", using: BFS)
  |> should.be_some
  |> should.equal(["a", "b"])
}

pub fn path_to_c_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "c", using: BFS)
  |> should.be_some
  |> should.equal(["a", "c"])
}

pub fn path_to_d_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "d", using: BFS)
  |> should.be_some
  |> should.equal(["a", "b", "d"])
}

pub fn path_to_e_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "e", using: BFS)
  |> should.be_some
  |> should.equal(["a", "c", "e"])
}

pub fn path_to_f_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "f", using: BFS)
  |> should.be_some
  |> should.equal(["a", "b", "d", "f"])
}

pub fn path_to_g_test() {
  example
  |> graph.from_string(" -> ")
  |> search.path(from: "a", to: "g", using: BFS)
  |> should.be_none
}
