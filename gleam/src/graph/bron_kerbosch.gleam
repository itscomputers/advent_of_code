import gleam/list

import graph/graph.{type Graph}

type BronKerbosch(a) {
  BK(
    graph: Graph(a),
    clique: List(a),
    candidates: List(a),
    excluded: List(a),
    cliques: List(List(a)),
  )
}

pub fn maximal_cliques(graph: Graph(a)) -> List(List(a)) {
  BK(
    graph:,
    clique: [],
    candidates: graph |> graph.vertices,
    excluded: [],
    cliques: [],
  )
  |> bron_kerbosch
  |> cliques
}

fn bron_kerbosch(bk: BronKerbosch(a)) -> BronKerbosch(a) {
  case list.is_empty(bk.candidates) && list.is_empty(bk.excluded) {
    True -> BK(..bk, cliques: [bk.clique, ..bk.cliques])
    False -> bk |> loop
  }
}

fn loop(bk: BronKerbosch(a)) -> BronKerbosch(a) {
  case bk.candidates {
    [] -> bk
    [vertex, ..candidates] -> {
      let cliques =
        BK(
          ..bk,
          clique: [vertex, ..bk.clique],
          candidates: bk |> adjacent(candidates, to: vertex),
          excluded: bk |> adjacent(bk.excluded, to: vertex),
        )
        |> bron_kerbosch
        |> cliques
      let excluded = [vertex, ..bk.excluded]
      BK(..bk, candidates:, excluded:, cliques:)
      |> loop
    }
  }
}

fn adjacent(bk: BronKerbosch(a), vertices: List(a), to vertex: a) -> List(a) {
  vertices |> list.filter(graph.adjacent(bk.graph, vertex, _))
}

fn cliques(bk: BronKerbosch(a)) -> List(List(a)) {
  bk.cliques
}
