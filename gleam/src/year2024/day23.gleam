import args.{type Part, PartOne, PartTwo}
import gleam/function
import gleam/int
import gleam/list
import gleam/option
import gleam/order.{type Order}
import gleam/set.{type Set}
import gleam/string

import graph/bron_kerbosch
import graph/graph.{type Graph}
import util

type Party {
  Party(party: List(String))
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input |> lan |> party_count(string.starts_with(_, "t")) |> int.to_string
    PartTwo -> input |> lan |> max_party |> show_party
  }
}

fn lan(input: String) -> Graph(String) {
  input
  |> graph.from_string(sep: "-")
  |> make_bidirectional
}

fn make_bidirectional(lan: Graph(String)) -> Graph(String) {
  lan
  |> graph.vertices
  |> list.fold(from: lan, with: fn(acc, vertex) {
    lan
    |> graph.neighbors(of: vertex)
    |> list.fold(from: acc, with: fn(acc, neighbor) {
      acc |> graph.add(neighbor, vertex)
    })
  })
}

fn parties_of_three(lan: Graph(String)) -> Set(Party) {
  lan
  |> graph.vertices
  |> list.fold(from: set.new(), with: fn(acc, vertex) {
    lan
    |> graph.neighbors(of: vertex)
    |> list.combination_pairs
    |> list.filter(fn(p) { lan |> graph.adjacent(p.0, p.1) })
    |> list.map(fn(p) { [vertex, p.0, p.1] |> build_party })
    |> set.from_list
    |> set.union(acc)
  })
}

fn max_party(lan: Graph(String)) -> Party {
  lan
  |> maximal_parties
  |> util.max(by: compare_party)
  |> option.unwrap(Party([]))
}

fn maximal_parties(lan: Graph(String)) -> List(Party) {
  lan
  |> bron_kerbosch.maximal_cliques
  |> list.map(build_party)
}

fn party_count(lan: Graph(String), condition: fn(String) -> Bool) -> Int {
  lan
  |> parties_of_three
  |> set.fold(from: 0, with: fn(acc, party) {
    case party.party |> list.any(condition) {
      True -> acc + 1
      False -> acc
    }
  })
}

fn build_party(vertices: List(String)) -> Party {
  Party(vertices |> list.sort(by: string.compare))
}

fn show_party(party: Party) -> String {
  party.party |> string.join(",")
}

fn compare_party(p1: Party, p2: Party) -> Order {
  int.compare(p2.party |> list.length, p1.party |> list.length)
}
