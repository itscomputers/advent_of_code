import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/result
import gleam/set

import args.{type Part, PartOne, PartTwo}
import direction.{type Direction, Down, Left, Right, Up}
import graph/graph.{type Graph}
import graph/search
import grid.{type Grid}
import point.{type Point, Point}

type Node {
  Node(pt: Point, dir: Direction)
}

type Maze {
  Maze(
    graph: Graph(Node),
    start: Node,
    end: List(Node),
    distances: Dict(Node, Int),
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> maze |> min_score |> int.to_string
    PartTwo -> input |> maze |> best_location_count |> int.to_string
  }
}

fn min_score(maze: Maze) -> Int {
  maze.distances
  |> dict.filter(fn(node, _) { maze.end |> list.contains(node) })
  |> dict.values
  |> list.sort(by: int.compare)
  |> list.first
  |> result.unwrap(or: 0)
}

fn best_location_count(maze: Maze) -> Int {
  let min_score = maze |> min_score
  let targets =
    maze.end
    |> list.filter(fn(node) {
      maze.distances |> dict.get(node) == Ok(min_score)
    })
  targets
  |> list.fold(from: set.new(), with: fn(acc, target) {
    acc
    |> set.union(
      maze.graph
      |> search.best_path_points(to: target, using: maze.distances)
      |> set.map(fn(node) { node.pt }),
    )
  })
  |> set.size
}

fn maze(input: String) -> Maze {
  let grid = input |> grid.new
  let assert Ok(start_pt) =
    grid |> grid.filter(fn(ch) { ch == "S" }) |> list.first
  let assert Ok(end_pt) =
    grid |> grid.filter(fn(ch) { ch == "E" }) |> list.first
  Maze(
    graph: graph.new(),
    start: Node(start_pt, Right),
    end: direction.all() |> list.map(Node(end_pt, _)),
    distances: dict.new(),
  )
  |> populate_graph(grid)
  |> set_distances
}

fn set_distances(maze: Maze) -> Maze {
  let distances =
    maze.graph
    |> search.distances(from: maze.start, using: search.Dijkstra)
  Maze(..maze, distances:)
}

fn populate_graph(maze: Maze, grid: Grid) -> Maze {
  grid
  |> grid.filter(fn(ch) { ch != "#" })
  |> list.fold(from: maze, with: fn(acc, pt) { acc |> add_point(grid, pt) })
}

fn add_point(maze: Maze, grid: Grid, pt: Point) -> Maze {
  [Right, Down, Left, Up]
  |> list.fold(from: maze, with: fn(acc, dir) {
    acc |> add_point_dir(grid, pt, dir)
  })
}

fn add_point_dir(maze: Maze, grid: Grid, pt: Point, dir: Direction) -> Maze {
  let source = Node(pt, dir)
  [
    #(source, 1),
    #(Node(pt, dir |> direction.cw), 1000),
    #(Node(pt, dir |> direction.ccw), 1000),
  ]
  |> list.filter(fn(tuple) {
    let #(Node(pt, dir), _) = tuple
    let next = pt |> direction.step(dir)
    grid |> grid.get(next) != Some("#")
  })
  |> list.map(fn(tuple) {
    let #(node, weight) = tuple
    case weight {
      1 -> #(Node(..node, pt: node.pt |> direction.step(node.dir)), weight)
      _ -> #(node, weight)
    }
  })
  |> list.fold(from: maze, with: fn(acc, tuple) {
    acc |> add_edge(source, tuple.0, tuple.1)
  })
}

fn add_edge(maze: Maze, source: Node, target: Node, weight: Int) -> Maze {
  Maze(..maze, graph: maze.graph |> graph.add_weighted(source, target, weight))
}
