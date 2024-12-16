import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/set.{type Set}
import gleam/string
import gleam/string_tree

import direction.{type Direction, Down, Left, Right, Up} as dir
import grid.{type Grid}
import point.{type Point, Point}
import range.{Range}
import util

type Warehouse {
  Warehouse(
    robot: Point,
    walls: Set(Point),
    boxes: Dict(Point, Box),
    moves: List(Direction),
  )
}

type Box {
  Basic(pt: Point)
  Wide(pt: Point)
}

pub fn main(input: String, part: Part) -> String {
  input |> warehouse(part) |> loop |> gps |> int.to_string
}

fn warehouse(input: String, part: Part) -> Warehouse {
  let assert [grid_str, move_str] = input |> util.blocks
  let grid = case part {
    PartOne -> grid_str |> grid.new
    PartTwo -> grid_str |> widen |> grid.new
  }
  Warehouse(robot: Point(0, 0), walls: set.new(), boxes: dict.new(), moves: [])
  |> assign_walls(grid)
  |> assign_boxes(grid, part)
  |> assign_robot(grid)
  |> assign_moves(move_str)
}

fn widen(grid_str: String) -> String {
  grid_str
  |> string.replace(each: "#", with: "##")
  |> string.replace(each: "O", with: "[]")
  |> string.replace(each: ".", with: "..")
  |> string.replace(each: "@", with: "@.")
}

fn gps(warehouse: Warehouse) -> Int {
  warehouse.boxes
  |> dict.values
  |> list.unique
  |> list.map(fn(box) { box.pt |> point.dot(Point(1, 100)) })
  |> int.sum
}

fn assign_robot(warehouse: Warehouse, grid: Grid) -> Warehouse {
  let assert Ok(robot) = grid |> get_points("@") |> list.first
  Warehouse(..warehouse, robot:)
}

fn assign_walls(warehouse: Warehouse, grid: Grid) -> Warehouse {
  Warehouse(..warehouse, walls: grid |> get_points("#") |> set.from_list)
}

fn assign_boxes(warehouse: Warehouse, grid: Grid, part: Part) -> Warehouse {
  let boxes = case part {
    PartOne ->
      grid
      |> get_points("O")
      |> list.map(fn(pt) { #(pt, Basic(pt)) })
      |> dict.from_list
    PartTwo ->
      grid
      |> get_points("[")
      |> list.zip(grid |> get_points("]"))
      |> list.flat_map(fn(tuple) {
        let box = Wide(tuple.0)
        [#(tuple.0, box), #(tuple.1, box)]
      })
      |> dict.from_list
  }
  Warehouse(..warehouse, boxes:)
}

fn get_points(grid: Grid, str: String) -> List(Point) {
  grid |> grid.filter(fn(ch) { ch == str })
}

fn assign_moves(warehouse: Warehouse, str: String) -> Warehouse {
  let moves =
    str
    |> util.lines
    |> list.flat_map(string.to_graphemes)
    |> list.map(fn(ch) {
      case ch {
        ">" -> Right
        "^" -> Up
        "<" -> Left
        "v" -> Down
        _ -> panic
      }
    })
  Warehouse(..warehouse, moves:)
}

fn loop(warehouse: Warehouse) -> Warehouse {
  case warehouse.moves {
    [] -> warehouse
    [move, ..moves] -> Warehouse(..warehouse, moves:) |> handle(move) |> loop
  }
}

fn handle(warehouse: Warehouse, direction: Direction) -> Warehouse {
  let robot = warehouse.robot |> dir.step(direction)
  case
    set.contains(warehouse.walls, robot),
    dict.has_key(warehouse.boxes, robot)
  {
    True, _ -> warehouse
    False, False -> warehouse |> set_robot(robot)
    False, True -> warehouse |> handle_box(robot, direction)
  }
}

fn handle_box(
  warehouse: Warehouse,
  robot: Point,
  direction: Direction,
) -> Warehouse {
  let assert Ok(box) = warehouse.boxes |> dict.get(robot)
  case boxes_group(warehouse, direction, [], [box]) {
    None -> warehouse
    Some(group) -> {
      let moved = group |> list.map(move_box(_, direction))
      warehouse
      |> remove_boxes(group)
      |> add_boxes(moved)
      |> set_robot(robot)
    }
  }
}

fn boxes_group(
  warehouse: Warehouse,
  direction: Direction,
  group: List(Box),
  queue: List(Box),
) -> Option(List(Box)) {
  case queue {
    [] -> Some(group)
    [box, ..queue] ->
      case warehouse |> neighbors(of: box, in: direction) {
        None -> None
        Some(boxes) ->
          boxes_group(
            warehouse,
            direction,
            [box, ..group],
            list.append(queue, boxes),
          )
      }
  }
}

fn box_points(box: Box) -> List(Point) {
  case box {
    Basic(pt) -> [pt]
    Wide(pt) -> [pt, pt |> dir.step(Right)]
  }
}

fn move_box(box: Box, direction: Direction) -> Box {
  case box {
    Basic(pt) -> Basic(pt |> dir.step(direction))
    Wide(pt) -> Wide(pt |> dir.step(direction))
  }
}

fn neighbors(
  warehouse: Warehouse,
  of box: Box,
  in direction: Direction,
) -> Option(List(Box)) {
  case box {
    Basic(pt) -> {
      let next_pt = pt |> dir.step(direction)
      case
        warehouse.walls |> set.contains(next_pt),
        warehouse.boxes |> dict.get(next_pt)
      {
        True, _ -> None
        _, Ok(neighbor) -> Some([neighbor])
        _, Error(_) -> Some([])
      }
    }
    Wide(pt) -> {
      case direction {
        Left -> {
          let next_pt = pt |> dir.step(direction)
          case
            warehouse.walls |> set.contains(next_pt),
            warehouse.boxes |> dict.get(next_pt)
          {
            True, _ -> None
            _, Ok(neighbor) -> Some([neighbor])
            _, Error(_) -> Some([])
          }
        }
        Right -> {
          let next_pt = pt |> dir.move(direction, times: 2)
          case
            warehouse.walls |> set.contains(next_pt),
            warehouse.boxes |> dict.get(next_pt)
          {
            True, _ -> None
            _, Ok(neighbor) -> Some([neighbor])
            _, Error(_) -> Some([])
          }
        }
        _ -> {
          let pts = box |> box_points |> list.map(dir.step(_, direction))
          let is_wall =
            pts
            |> list.any(fn(pt) { warehouse.walls |> set.contains(pt) })
          let res =
            pts
            |> list.map(fn(pt) { warehouse.boxes |> dict.get(pt) })
          case is_wall, res {
            True, _ -> None
            _, [Ok(left), Ok(right)] -> Some([left, right])
            _, [Ok(left), Error(_)] -> Some([left])
            _, [Error(_), Ok(right)] -> Some([right])
            _, [Error(_), Error(_)] -> Some([])
            _, _ -> None
          }
        }
      }
    }
  }
}

fn set_robot(warehouse: Warehouse, robot: Point) -> Warehouse {
  Warehouse(..warehouse, robot:) |> remove_box_pts([robot])
}

fn add_boxes(warehouse: Warehouse, boxes: List(Box)) -> Warehouse {
  boxes |> list.fold(from: warehouse, with: add_box)
}

fn add_box(warehouse: Warehouse, box: Box) -> Warehouse {
  let boxes =
    box
    |> box_points
    |> list.fold(from: warehouse.boxes, with: fn(acc, pt) {
      acc |> dict.insert(pt, box)
    })
  Warehouse(..warehouse, boxes:)
}

fn remove_box_pts(warehouse: Warehouse, pts: List(Point)) -> Warehouse {
  let boxes = warehouse.boxes |> dict.drop(pts)
  Warehouse(..warehouse, boxes:)
}

fn remove_boxes(warehouse: Warehouse, boxes: List(Box)) -> Warehouse {
  warehouse |> remove_box_pts(boxes |> list.flat_map(box_points))
}

fn display(warehouse: Warehouse, dim: Point) -> Warehouse {
  util.println("", "")
  Range(0, dim.y)
  |> range.map(fn(y) {
    Range(0, dim.x)
    |> range.fold(from: string_tree.new(), with: fn(acc, x) {
      let pt = Point(x, y)
      let ch = case
        warehouse.robot == pt,
        warehouse.walls |> set.contains(pt),
        warehouse.boxes |> dict.get(pt)
      {
        True, _, _ -> "@"
        _, True, _ -> "#"
        _, _, Error(_) -> "."
        _, _, Ok(box) -> {
          case box {
            Basic(_) -> "O"
            Wide(pt2) if pt == pt2 -> "["
            _ -> "]"
          }
        }
      }
      acc |> string_tree.append(ch)
    })
    |> string_tree.to_string
    |> util.println("")
  })

  warehouse
}
