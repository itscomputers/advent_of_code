import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/result
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
    dimensions: Point,
  )
}

type Box {
  Basic(pt: Point)
  Wide(pt: Point)
}

type Collision {
  Wall
  Open
  Boxes(boxes: List(Box))
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
  Warehouse(
    robot: Point(0, 0),
    walls: set.new(),
    boxes: dict.new(),
    moves: [],
    dimensions: grid |> grid.dimensions,
  )
  |> assign_walls(grid)
  |> assign_boxes(grid, part)
  |> assign_robot(grid)
  |> assign_moves(move_str)
  |> display(False)
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
  |> list.map(distance)
  |> int.sum
}

fn distance(box: Box) -> Int {
  box.pt |> point.dot(Point(1, 100))
}

fn assign_robot(warehouse: Warehouse, grid: Grid) -> Warehouse {
  let assert Ok(robot) = grid |> get_points(["@"]) |> list.first
  Warehouse(..warehouse, robot:)
}

fn assign_walls(warehouse: Warehouse, grid: Grid) -> Warehouse {
  Warehouse(..warehouse, walls: grid |> get_points(["#"]) |> set.from_list)
}

fn assign_boxes(warehouse: Warehouse, grid: Grid, part: Part) -> Warehouse {
  let boxes =
    grid
    |> get_points(["O", "["])
    |> list.map(fn(pt) {
      case part {
        PartOne -> #(pt, Basic(pt))
        PartTwo -> #(pt, Wide(pt))
      }
    })
    |> dict.from_list
  Warehouse(..warehouse, boxes:)
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
    [move, ..moves] ->
      Warehouse(..warehouse, moves:)
      |> handle(move)
      |> loop
  }
}

fn handle(warehouse: Warehouse, direction: Direction) -> Warehouse {
  let pt = warehouse.robot |> dir.step(direction)
  case warehouse |> has_wall(at: pt), warehouse |> get_box(at: pt) {
    True, _ -> warehouse
    _, None -> warehouse |> set_robot(pt)
    _, Some(box) ->
      case warehouse |> try_move(box, direction) {
        Ok(warehouse) -> warehouse |> set_robot(pt)
        Error(_) -> warehouse
      }
  }
}

fn try_move(
  warehouse: Warehouse,
  box: Box,
  direction: Direction,
) -> Result(Warehouse, Nil) {
  let pt = box.pt |> dir.step(direction)
  let moved_box = case box {
    Basic(_) -> Basic(pt)
    Wide(_) -> Wide(pt)
  }
  let do_move = fn(w) { w |> remove_box(at: box.pt) |> add_box(moved_box) }
  case warehouse |> collision(box, direction) {
    Wall -> Error(Nil)
    Open -> Ok(warehouse |> do_move)
    Boxes(boxes) ->
      boxes
      |> list.fold(from: Ok(warehouse), with: fn(res, b) {
        res |> result.try(try_move(_, b, direction))
      })
      |> result.map(do_move)
  }
}

fn collision(warehouse: Warehouse, box: Box, direction: Direction) -> Collision {
  let pts = case box, direction {
    Basic(pt), _ -> [pt |> dir.step(direction)]
    Wide(pt), Left -> [pt |> dir.step(Left)]
    Wide(pt), Right -> [pt |> dir.move(Right, times: 2)]
    Wide(pt), _ ->
      [pt, pt |> dir.step(Right)] |> list.map(dir.step(_, direction))
  }
  case pts |> list.any(has_wall(warehouse, _)) {
    True -> Wall
    False ->
      case pts |> list.all(is_open(warehouse, _)) {
        True -> Open
        False ->
          pts
          |> list.map(get_box(warehouse, _))
          |> list.fold(from: [], with: fn(acc, opt) {
            case opt {
              Some(b) -> [b, ..acc]
              None -> acc
            }
          })
          |> list.unique
          |> Boxes
      }
  }
}

fn has_wall(warehouse: Warehouse, at pt: Point) -> Bool {
  warehouse.walls |> set.contains(pt)
}

fn get_box(warehouse: Warehouse, at pt: Point) -> Option(Box) {
  case
    warehouse.boxes |> dict.get(pt),
    warehouse.boxes |> dict.get(pt |> dir.step(Left))
  {
    Ok(box), _ -> Some(box)
    Error(_), Ok(Wide(pt)) -> Some(Wide(pt))
    _, _ -> None
  }
}

fn is_open(warehouse: Warehouse, at pt: Point) -> Bool {
  case warehouse |> has_wall(at: pt), warehouse |> get_box(at: pt) {
    True, _ -> False
    _, Some(_) -> False
    _, _ -> True
  }
}

fn set_robot(warehouse: Warehouse, robot: Point) -> Warehouse {
  let boxes = warehouse.boxes |> dict.drop([robot])
  Warehouse(..warehouse, robot:, boxes:)
}

fn add_box(warehouse: Warehouse, box: Box) -> Warehouse {
  let boxes = warehouse.boxes |> dict.insert(box.pt, box)
  Warehouse(..warehouse, boxes:)
}

fn remove_box(warehouse: Warehouse, at pt: Point) -> Warehouse {
  let boxes = warehouse.boxes |> dict.delete(pt)
  Warehouse(..warehouse, boxes:)
}

fn get_points(grid: Grid, strings: List(String)) -> List(Point) {
  grid |> grid.filter(fn(ch) { strings |> list.contains(ch) })
}

fn display(warehouse: Warehouse, show: Bool) -> Warehouse {
  case show {
    False -> Nil
    True -> {
      util.println("", "")
      Range(0, warehouse.dimensions.y)
      |> range.each(fn(y) {
        Range(0, warehouse.dimensions.x)
        |> range.fold(from: string_tree.new(), with: fn(acc, x) {
          let pt = Point(x, y)
          let ch = case
            warehouse.robot == pt,
            warehouse |> has_wall(at: pt),
            warehouse |> get_box(at: pt)
          {
            True, _, _ -> "@"
            _, True, _ -> "#"
            _, _, None -> "."
            _, _, Some(box) -> {
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
    }
  }
  warehouse
}
