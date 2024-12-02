import gleam/dict
import gleeunit
import gleeunit/should

import graph
import graph_search.{Dijkstra}

// a -----> b -----> d -----> f
// \   5        7    ^   10
//  \               4|
//   \  2       3    v    6
//    \---> c -----> e <----- g
const example = [
  #("a", "b", 5), #("a", "c", 2), #("d", "f", 10), #("b", "d", 7),
  #("c", "e", 3), #("d", "e", 4), #("g", "e", 6), #("e", "d", 4),
]

pub fn main() {
  gleeunit.main()
}

pub fn distances_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.distances(from: "a", using: Dijkstra)
  |> should.equal(
    [#("a", 0), #("b", 5), #("c", 2), #("d", 9), #("e", 5), #("f", 19)]
    |> dict.from_list,
  )
}

pub fn path_to_a_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "a", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a"])
}

pub fn path_to_b_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "b", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a", "b"])
}

pub fn path_to_c_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "c", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a", "c"])
}

pub fn path_to_d_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "d", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a", "c", "e", "d"])
}

pub fn path_to_e_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "e", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a", "c", "e"])
}

pub fn path_to_f_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "f", using: Dijkstra)
  |> should.be_some
  |> should.equal(["a", "c", "e", "d", "f"])
}

pub fn path_to_g_test() {
  example
  |> graph.from_weighted_list
  |> graph_search.path(from: "a", to: "g", using: Dijkstra)
  |> should.be_none
}
