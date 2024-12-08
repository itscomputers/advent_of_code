import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/otp/task.{type Task}
import gleam/set.{type Set}

import direction.{type Direction} as dir
import grid.{type Grid}
import point.{type Point, Point}
import range.{type Range, Range}
import util

type Patrol {
  Patrol(
    grid: Grid,
    guard: Point,
    direction: Direction,
    visited: Dict(Point, Set(Direction)),
    check_loops: Bool,
    is_loop: Bool,
    loop_tasks: Dict(Point, Task(Bool)),
    ranges: Dict(#(Direction, Int), List(Range)),
    possible_obstructions: Set(Point),
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> grid.new
      |> patrol(False)
      |> visited_count
      |> int.to_string
    PartTwo ->
      input
      |> grid.new
      |> patrol(True)
      |> possible_obstruction_count
      |> int.to_string
  }
}

fn patrol(grid: Grid, check_loops: Bool) -> Patrol {
  case
    grid
    |> function.tap(fn(g) { g |> grid.dimensions })
    |> grid.filter(fn(ch) { ch == "^" })
  {
    [] -> panic
    [guard, ..] ->
      Patrol(
        grid:,
        guard:,
        direction: Up,
        visited: dict.new(),
        check_loops:,
        is_loop: False,
        loop_tasks: dict.new(),
        ranges: dict.new(),
        possible_obstructions: set.new(),
      )
      |> visit
      |> explore
  }
}

fn sub_patrol(grid: Grid, obstruction: Point) -> Patrol {
  case grid |> grid.filter(fn(ch) { ch == "^" }) {
    [] -> panic
    [guard, ..] ->
      Patrol(
        grid: grid |> grid.set(obstruction, "#"),
        guard:,
        direction: Up,
        visited: dict.new(),
        check_loops: False,
        is_loop: False,
        loop_tasks: dict.new(),
        ranges: dict.new(),
        possible_obstructions: set.new(),
      )
      |> visit
      |> explore
  }
}

fn is_loop(patrol: Patrol) -> Bool {
  patrol.is_loop
}

fn visited_count(patrol: Patrol) -> Int {
  patrol.visited |> dict.size
}

fn possible_obstruction_count(patrol: Patrol) -> Int {
  patrol.loop_tasks
  |> function.tap(fn(tasks) { tasks |> dict.size |> util.debug("tasks") })
  |> dict.map_values(fn(_, t) { task.await_forever(t) })
  |> dict.fold(from: 0, with: fn(acc, _, bool) {
    case bool {
      True -> acc + 1
      False -> acc
    }
  })
}

fn move(patrol: Patrol) -> Patrol {
  Patrol(..patrol, guard: patrol |> next)
}

fn turn(patrol: Patrol) -> Patrol {
  Patrol(..patrol, direction: patrol.direction |> dir.cw)
}

fn next(patrol: Patrol) -> Point {
  patrol.guard |> dir.step(patrol.direction)
}

fn peek(patrol: Patrol) -> Option(String) {
  patrol |> next |> grid.get(patrol.grid, _)
}

fn explore(patrol: Patrol) -> Patrol {
  case patrol.is_loop, patrol |> peek {
    False, Some("#") ->
      patrol
      |> turn
      |> visit
      |> explore
    False, Some(_) ->
      patrol
      |> add_loop_task
      |> move
      |> visit
      |> explore
    True, _ | _, None -> patrol
  }
}

fn visit(patrol: Patrol) -> Patrol {
  case patrol.visited |> dict.get(patrol.guard) {
    Ok(directions) ->
      case directions |> set.contains(patrol.direction) {
        True -> Patrol(..patrol, is_loop: True)
        False ->
          Patrol(
            ..patrol,
            visited: patrol.visited
              |> dict.insert(
                patrol.guard,
                directions |> set.insert(patrol.direction),
              ),
          )
      }
    Error(_) ->
      Patrol(
        ..patrol,
        visited: patrol.visited
          |> dict.insert(patrol.guard, set.from_list([patrol.direction])),
      )
  }
}

fn add_loop_task(patrol: Patrol) -> Patrol {
  let obs = patrol |> next
  case
    patrol.check_loops,
    patrol.grid |> grid.get(obs),
    patrol.loop_tasks |> dict.has_key(obs)
  {
    True, Some("."), False -> {
      let task =
        task.async(fn() {
          patrol.grid
          |> sub_patrol(obs)
          |> is_loop
        })
      Patrol(..patrol, loop_tasks: patrol.loop_tasks |> dict.insert(obs, task))
    }
    _, _, _ -> patrol
  }
}
