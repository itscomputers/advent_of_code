import gleam/io

import args.{type Args}
import util
import year2024/day01
import year2024/day02

pub fn run(a: Args) -> Nil {
  case a.day {
    "01" -> day01.main(a) |> io.println
    "02" -> day02.main(a) |> io.println
    _ -> {
      util.debug(a, "unimplemented")
      Nil
    }
  }
}
