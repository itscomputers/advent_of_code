import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp.{type Match}

import args.{type Args, type Part, PartOne, PartTwo}
import regex
import util

pub fn main(a: Args) -> String {
  a
  |> args.input
  |> run(a.part)
}

pub fn run(input: String, part: Part) -> String {
  input
  |> util.lines
  |> list.map(fn(line) {
    line
    |> regex.matches(part |> pattern)
    |> extract
  })
  |> list.fold(0, fn(acc, res) {
    case res {
      Ok(value) -> acc + value
      _ -> acc
    }
  })
  |> int.to_string
}

fn pattern(part: Part) -> String {
  case part {
    PartOne -> "[1-9]"
    PartTwo -> "[1-9]|(?=(one|two|three|four|five|six|seven|eight|nine))"
  }
}

fn extract(matches: List(Match)) -> Result(Int, Nil) {
  case matches |> list.first, matches |> list.last {
    Ok(first), Ok(last) -> { convert(first) <> convert(last) } |> int.parse
    _, _ -> {
      util.debug(matches, "matches")
      Error(Nil)
    }
  }
}

fn convert(match: Match) -> String {
  case match.content, match.submatches {
    "", [Some("one")] -> "1"
    "", [Some("two")] -> "2"
    "", [Some("three")] -> "3"
    "", [Some("four")] -> "4"
    "", [Some("five")] -> "5"
    "", [Some("six")] -> "6"
    "", [Some("seven")] -> "7"
    "", [Some("eight")] -> "8"
    "", [Some("nine")] -> "9"
    str, _ -> str
  }
}
