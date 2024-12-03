import gleam/io
import gleam/string

import argv

import args.{type Args, type Part, Args, Both, PartOne, PartTwo}
import util
import year2023/main as y23
import year2024/main as y24

pub fn main() {
  let args = get_args()
  let func = args |> get_func
  let input = args |> args.input
  case args {
    Args(_, _, part) -> func(input, part)
    Both(..) ->
      [func(input, PartOne), func(input, PartTwo)]
      |> string.join("\n")
  }
  |> io.println
}

fn get_func(a: Args) -> fn(String, Part) -> String {
  case a.year {
    "2023" -> y23.get_func(a.day)
    "2024" -> y24.get_func(a.day)
    _ -> {
      util.debug(a, "invalid args")
      panic
    }
  }
}

fn get_args() -> Args {
  case argv.load().arguments {
    [year, day, "1"] -> Args(year:, day:, part: PartOne)
    [year, day, "2"] -> Args(year:, day:, part: PartTwo)
    [year, day] -> Both(year:, day:)
    _ -> {
      io.println("usage: gleam run <year> <day> <part>, eg gleam run 2023 01 1")
      panic
    }
  }
}
