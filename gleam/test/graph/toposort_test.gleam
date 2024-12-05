import gleeunit
import gleeunit/should

import graph/graph
import graph/toposort
import graph/util

// a -----> b -----> d -----> f
// \                 ^
//  \                |
//   \               |
//    \---> c -----> e <----- g
const example = "a -> b
a -> c
d -> f
b -> d
c -> e
g -> e
e -> d"

pub fn main() {
  gleeunit.main()
}

pub fn sort_test() {
  let gr = example |> graph.from_string(sep: " -> ")
  gr
  |> toposort.sort
  |> should.be_some
  |> util.is_sorted(gr, _)
  |> should.be_true
}
