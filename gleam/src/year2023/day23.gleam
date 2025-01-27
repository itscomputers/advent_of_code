import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{Some}
import util

import args.{type Part, PartOne, PartTwo}
import direction.{type Direction, Down, Left, Right, Up} as dir
import graph/graph.{type Graph}
import graph/util as graph_util
import grid.{type Grid}
import iset.{type ISet}
import point.{type Point, Point}

pub fn main(input: String, part: Part) -> String {
  input |> build_hike |> condense(part) |> max_dist |> int.to_string
}

type Hike {
  Hike(
    graph: Graph(Point),
    start: Point,
    end: Point,
    crests: Dict(Point, Direction),
    slopes: Dict(Point, Direction),
  )
}

type IHike {
  IHike(graph: Graph(Int), start: Int, end: Int)
}

type Builder {
  Builder(grid: Grid, points: List(Point), last: Point, hike: Hike)
}

fn max_dist(hike: IHike) -> Int {
  dist_loop(hike, hike.start, 0, iset.new())
}

fn dist_loop(hike: IHike, pt: Int, dist: Int, visited: ISet) -> Int {
  case pt == hike.end {
    True -> dist
    False ->
      graph.neighbors(hike.graph, of: pt)
      |> list.filter(fn(nbr) { !iset.contains(visited, nbr) })
      |> list.fold(from: 0, with: fn(acc, nbr) {
        dist_loop(
          hike,
          nbr,
          dist + graph.weight(hike.graph, from: pt, to: nbr),
          visited |> iset.insert(pt),
        )
        |> int.max(acc)
      })
  }
}

fn ihike(hike: Hike) -> IHike {
  let transform =
    hike.graph
    |> graph.vertices
    |> list.index_map(fn(pt, idx) { #(pt, idx) })
    |> dict.from_list
  let i = fn(pt) {
    case dict.get(transform, pt) {
      Ok(value) -> value
      Error(_) -> {
        util.println(pt, "error")
        panic
      }
    }
  }
  let graph =
    hike.graph
    |> graph.edges
    |> list.fold(from: graph.new(), with: fn(acc, edge) {
      acc |> graph.add_weighted(i(edge.from), i(edge.to), edge.weight)
    })
  let start = i(hike.start)
  let end = i(hike.end)
  IHike(graph:, start:, end:)
}

fn condense(hike: Hike, part: Part) -> IHike {
  let graph = case part {
    PartOne -> {
      let vertices = hike.slopes |> dict.keys
      graph_util.condense(hike.graph, from: vertices, to: vertices)
    }
    PartTwo -> {
      let crests = hike.crests |> dict.keys
      let init_gr =
        graph_util.condense(hike.graph, from: [hike.start], to: crests)
      let crest_gr = graph_util.condense(hike.graph, from: crests, to: crests)
      let graph =
        init_gr
        |> graph.edges
        |> list.fold(from: graph.new(), with: fn(acc, edge) {
          let from = edge.from
          let to = edge.to
          let weight = edge.weight
          graph.add_weighted(acc, from:, to:, weight:)
        })
      crest_gr
      |> graph.edges
      |> list.filter(fn(edge) { edge.to != hike.end })
      |> list.fold(from: graph, with: fn(acc, edge) {
        let assert Ok(direction) = hike.crests |> dict.get(edge.to)
        case dir.step(edge.to, direction) == hike.end {
          True ->
            graph.add_weighted(
              acc,
              from: edge.from,
              to: dir.step(edge.to, direction),
              weight: edge.weight + 1,
            )
          False ->
            acc
            |> graph.add_weighted(
              from: edge.from,
              to: edge.to,
              weight: edge.weight,
            )
            |> graph.add_weighted(
              from: edge.to,
              to: edge.from,
              weight: edge.weight,
            )
        }
      })
    }
  }
  Hike(..hike, graph:) |> ihike
}

fn build_hike(input: String) -> Hike {
  let grid = grid.new(input)
  let start = Point(1, 0)
  let last = start |> dir.step(Up)
  let end = grid |> grid.dimensions |> point.add(Point(-1, 0))
  let graph = graph.new()
  let crests = dict.new()
  let slopes =
    dict.new()
    |> dict.insert(start, Down)
    |> dict.insert(end, Down)
  let hike = Hike(graph:, start:, end:, crests:, slopes:)
  Builder(grid:, points: [Point(1, 0)], last:, hike:)
  |> build_loop
}

fn build_loop(builder: Builder) -> Hike {
  case builder.points {
    [] -> builder.hike
    [pt, ..points] ->
      process_point(Builder(..builder, points:), pt)
      |> build_loop
  }
}

fn process_point(builder: Builder, pt: Point) -> Builder {
  case builder.grid |> grid.get(pt) {
    Some(">") -> process_slope(builder, pt, Right)
    Some("<") -> process_slope(builder, pt, Left)
    Some("^") -> process_slope(builder, pt, Up)
    Some("v") -> process_slope(builder, pt, Down)
    Some(".") ->
      point.strict_neighbors(of: pt)
      |> list.fold(from: builder, with: fn(acc, nbr) {
        process_edge(acc, pt, nbr)
      })
    _ -> builder
  }
  |> update_last(to: pt)
}

fn update_last(builder: Builder, to last: Point) -> Builder {
  Builder(..builder, last:)
}

fn process_slope(builder: Builder, pt: Point, direction: Direction) -> Builder {
  let slopes = builder.hike.slopes |> dict.insert(pt, direction)
  Builder(..builder, hike: Hike(..builder.hike, slopes:))
  |> process_edge(pt, pt |> dir.step(direction))
}

fn process_crest(builder: Builder, pt: Point, direction: Direction) -> Builder {
  let crests = builder.hike.crests |> dict.insert(pt, direction)
  Builder(..builder, hike: Hike(..builder.hike, crests:))
  |> add_edge(pt, pt |> dir.step(direction))
}

fn process_edge(builder: Builder, pt: Point, nbr: Point) -> Builder {
  case nbr == builder.last {
    True -> builder
    False ->
      case nbr == builder.hike.end {
        True -> process_crest(builder, pt, Down)
        False ->
          case
            builder.grid |> grid.get(nbr),
            point.subtract(nbr, pt) |> dir.from_point
          {
            Some("#"), _ -> builder
            Some(">"), Some(Left) -> builder
            Some("<"), Some(Right) -> builder
            Some("^"), Some(Down) -> builder
            Some("v"), Some(Up) -> builder
            Some(">"), Some(Right) -> process_crest(builder, pt, Right)
            Some("<"), Some(Left) -> process_crest(builder, pt, Left)
            Some("^"), Some(Up) -> process_crest(builder, pt, Up)
            Some("v"), Some(Down) -> process_crest(builder, pt, Down)
            Some(_), Some(_) -> add_edge(builder, pt, nbr)
            _, _ -> builder
          }
      }
  }
}

fn add_edge(builder: Builder, pt: Point, nbr: Point) -> Builder {
  let graph = builder.hike.graph |> graph.add(pt, nbr)
  let hike = Hike(..builder.hike, graph:)
  let points = [nbr, ..builder.points]
  Builder(..builder, points:, hike:)
}
