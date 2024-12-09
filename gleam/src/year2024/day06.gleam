import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/option.{type Option, None, Some}
import gleam/otp/task.{type Task}
import gleam/result
import gleam/set.{type Set}

import direction.{type Direction, Up} as dir
import grid.{type Grid}
import point.{type Point, Point}

type Patrol {
  Patrol(
    grid: Grid,
    guard: Point,
    direction: Direction,
    visited: Dict(Point, Set(Direction)),
    check_loops: Bool,
    is_loop: Bool,
    loop_tasks: Dict(Point, Task(Bool)),
    possible_obstructions: Set(Point),
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> grid.new
      |> patrol(loops: False)
      |> explore
      |> visited_count
      |> int.to_string
    PartTwo ->
      input
      |> grid.new
      |> patrol(loops: True)
      |> explore
      |> possible_obstruction_count
      |> int.to_string
  }
}

fn patrol(grid: Grid, loops check_loops: Bool) -> Patrol {
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
        visited: [#(guard, set.from_list([Up]))] |> dict.from_list,
        check_loops:,
        is_loop: False,
        loop_tasks: dict.new(),
        possible_obstructions: set.new(),
      )
  }
}

fn sub_patrol(grid: Grid, obstruction: Point) -> Patrol {
  grid |> grid.set(obstruction, "#") |> patrol(loops: False)
}

fn is_loop(patrol: Patrol) -> Bool {
  patrol.is_loop
}

fn visited_count(patrol: Patrol) -> Int {
  patrol.visited |> dict.size
}

fn possible_obstruction_count(patrol: Patrol) -> Int {
  patrol.loop_tasks
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
  let visited =
    patrol.visited
    |> dict.upsert(update: patrol.guard, with: fn(opt) {
      case opt {
        Some(directions) -> directions |> set.insert(patrol.direction)
        None -> set.from_list([patrol.direction])
      }
    })
  let is_loop =
    patrol.visited
    |> dict.get(patrol.guard)
    |> result.map(set.contains(_, patrol.direction))
    == Ok(True)
  Patrol(..patrol, visited:, is_loop:)
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
        task.async(fn() { patrol.grid |> sub_patrol(obs) |> explore |> is_loop })
      Patrol(..patrol, loop_tasks: patrol.loop_tasks |> dict.insert(obs, task))
    }
    _, _, _ -> patrol
  }
}
