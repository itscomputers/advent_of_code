import gleam/io
import gleam/string
import simplifile as sf

import util

pub type Part {
  PartOne
  PartTwo
}

pub type Args {
  Args(year: String, day: String, part: Part)
  Both(year: String, day: String)
}

pub fn with_part(year: String, day: String, part: String) -> Args {
  Args(year:, day: sanitize_day(day), part: sanitize_part(part))
}

pub fn without_part(year: String, day: String) -> Args {
  Both(year:, day: sanitize_day(day))
}

pub fn input(args: Args) -> String {
  case sf.read(args |> input_filename) {
    Ok(input) -> input
    _ -> {
      util.debug(args, "missing input")
      panic
    }
  }
}

fn input_filename(args: Args) -> String {
  "../inputs/" <> args.year <> "/" <> args.day <> ".txt"
}

fn sanitize_day(day: String) -> String {
  case day |> string.length {
    1 -> "0" <> day
    _ -> day
  }
}

fn sanitize_part(part: String) -> Part {
  case part {
    "1" -> PartOne
    "2" -> PartTwo
    _ -> {
      io.println("usage: gleam run <year> <day> <part>, eg gleam run 2023 01 1")
      panic
    }
  }
}
