import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{None, Some}
import gleam/set.{type Set}
import util

import args.{type Part, PartOne, PartTwo}
import direction.{Down, Left, Right, Up} as dir
import graph/bfs
import graph/graph.{type Edge, type Graph}
import grid.{type Grid}
import iset.{type ISet}
import point.{type Point, Point}

type Hike {
  Hike(graph: Graph(Point), source: Point, target: Point, slopes: Set(Point))
}

type ContractedHike {
  ContractedHike(graph: Graph(Int), source: Int, target: Int)
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> hike(part) |> contract |> max |> int.to_string
    PartTwo -> input |> hike(part) |> contracted_hike |> max |> int.to_string
  }
}

fn max(hike: ContractedHike) -> Int {
  max_loop(hike, hike.source, 0, iset.new())
}

fn max_loop(hike: ContractedHike, pt: Int, distance: Int, visited: ISet) -> Int {
  case pt == hike.target {
    True -> distance
    False -> {
      let visited = visited |> iset.add(pt)
      hike.graph
      |> graph.neighbors(of: pt)
      |> list.filter(fn(neighbor) { !iset.contains(visited, neighbor) })
      |> list.fold(from: 0, with: fn(acc, neighbor) {
        max_loop(
          hike,
          neighbor,
          distance + graph.weight(hike.graph, from: pt, to: neighbor),
          visited,
        )
        |> int.max(acc)
      })
    }
  }
}

fn hike(input: String, part: Part) -> Hike {
  let grid = input |> grid.new
  let source = Point(1, 0)
  let target =
    grid
    |> grid.dimensions
    |> point.add(Point(-1, 0))
  let slopes =
    grid
    |> grid.filter(list.contains(["^", "v", "<", ">"], _))
    |> set.from_list
  Hike(graph: graph.new(), source:, target:, slopes:)
  |> hike_loop(grid, [source], set.new(), part)
}

fn hike_loop(
  hike: Hike,
  grid: Grid,
  pts: List(Point),
  visited: Set(Point),
  part: Part,
) -> Hike {
  case pts {
    [] -> hike
    [pt, ..pts] ->
      case visited |> set.contains(pt) {
        True -> hike_loop(hike, grid, pts, visited, part)
        False -> {
          let assert Some(ch) = grid |> grid.get(pt)
          let graph =
            pt
            |> point.strict_neighbors
            |> list.fold(from: hike.graph, with: fn(acc, npt) {
              case grid |> grid.get(npt) {
                Some(nch) -> process_edge(acc, pt, ch, npt, nch, part)
                None -> acc
              }
            })
          let pts =
            pt
            |> point.strict_neighbors
            |> list.fold(from: pts, with: fn(acc, npt) {
              case grid |> grid.get(npt) {
                Some(_) -> [npt, ..acc]
                None -> acc
              }
            })
          let visited = visited |> set.insert(pt)
          Hike(..hike, graph:) |> hike_loop(grid, pts, visited, part)
        }
      }
  }
}

fn contract(hike: Hike) -> ContractedHike {
  case
    hike
    |> edges_to_contract
    |> function.tap(fn(l) { util.println(list.length(l), "remaining") })
  {
    [] -> hike |> display |> transform
    [edge, ..] -> {
      let graph = hike.graph |> graph.contract(edge)
      Hike(..hike, graph:) |> contract
    }
  }
}

fn transform(hike: Hike) -> ContractedHike {
  let transform =
    hike.graph
    |> graph.vertices
    |> list.index_map(fn(vertex, index) { #(vertex, index) })
    |> dict.from_list

  let graph =
    hike.graph
    |> graph.vertices
    |> list.fold(from: graph.new(), with: fn(acc, vertex) {
      hike.graph
      |> graph.neighbors(of: vertex)
      |> list.fold(from: acc, with: fn(acc, neighbor) {
        let assert Ok(v) = transform |> dict.get(vertex)
        let assert Ok(n) = transform |> dict.get(neighbor)
        let weight = hike.graph |> graph.weight(from: vertex, to: neighbor)
        acc |> graph.add_weighted(from: v, to: n, weight:)
      })
    })

  let assert Ok(source) = transform |> dict.get(hike.source)
  let assert Ok(target) = transform |> dict.get(hike.target)
  ContractedHike(graph:, source:, target:)
}

fn edges_to_contract(hike: Hike) -> List(Edge(Point)) {
  hike.graph
  |> graph.edges
  |> list.filter(fn(edge) {
    edge.to != hike.target && !set.contains(hike.slopes, edge.to)
  })
}

fn contracted_hike(hike: Hike) -> ContractedHike {
  let Hike(graph, source, target, slopes) = hike
  let graph =
    [source, target, ..slopes |> set.to_list]
    |> list.fold(from: graph.new(), with: fn(acc, vertex) {
      let slopes = set.delete(slopes, vertex)
      graph
      |> bfs.distances(from: vertex, until: set.contains(slopes, _))
      |> dict.take([source, target, ..slopes |> set.to_list])
      |> dict.fold(from: acc, with: fn(acc, neighbor, weight) {
        case vertex == neighbor {
          True -> acc
          False ->
            acc |> graph.add_weighted(from: vertex, to: neighbor, weight:)
        }
      })
    })

  let transform =
    graph
    |> graph.vertices
    |> list.index_map(fn(vertex, index) { #(vertex, index) })
    |> dict.from_list

  let graph =
    graph
    |> graph.vertices
    |> list.fold(from: graph.new(), with: fn(acc, vertex) {
      graph
      |> graph.neighbors(of: vertex)
      |> list.fold(from: acc, with: fn(acc, neighbor) {
        let assert Ok(v) = transform |> dict.get(vertex)
        let assert Ok(n) = transform |> dict.get(neighbor)
        let weight = graph |> graph.weight(from: vertex, to: neighbor)
        acc |> graph.add_weighted(from: v, to: n, weight:)
      })
    })

  let assert Ok(source) = transform |> dict.get(source)
  let assert Ok(target) = transform |> dict.get(target)
  ContractedHike(graph:, source:, target:)
}

fn process_edge(
  graph: Graph(Point),
  pt: Point,
  ch: String,
  npt: Point,
  nch: String,
  part: Part,
) -> Graph(Point) {
  let direction = npt |> point.subtract(pt) |> dir.from_point_unsafe
  case ch, direction, nch, part {
    "#", _, _, _ -> graph
    _, _, "#", _ -> graph
    _, _, _, PartTwo -> graph |> graph.add(pt, npt)
    _, Up, "v", _ -> graph
    _, Down, "^", _ -> graph
    _, Right, "<", _ -> graph
    _, Left, ">", _ -> graph
    ".", _, _, _ -> graph |> graph.add(pt, npt)
    "^", Up, _, _ -> graph |> graph.add(pt, npt)
    "v", Down, _, _ -> graph |> graph.add(pt, npt)
    "<", Left, _, _ -> graph |> graph.add(pt, npt)
    ">", Right, _, _ -> graph |> graph.add(pt, npt)
    _, _, _, _ -> graph
  }
}

fn display(hike: Hike) -> Hike {
  hike.graph |> graph.display
  hike
}
