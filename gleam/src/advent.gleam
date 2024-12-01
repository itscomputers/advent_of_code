import gleam/io

import argv

import args.{type Args, Args, PartOne, PartTwo}
import util
import year2023
import year2024

pub fn main() {
  let args = get_args()
  case args.year {
    "2023" -> year2023.run(args)
    "2024" -> year2024.run(args)
    _ -> {
      util.debug(args, "invalid args")
      panic
    }
  }
}

fn get_args() -> Args {
  case argv.load().arguments {
    [year, day, "1"] -> Args(year, day, PartOne)
    [year, day, "2"] -> Args(year, day, PartTwo)
    _ -> {
      io.println("usage: gleam run <year> <day> <part>, eg gleam run 2023 01 1")
      panic
    }
  }
}
