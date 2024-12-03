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
