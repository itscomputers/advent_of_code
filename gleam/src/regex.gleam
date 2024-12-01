import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/regexp.{type Match, type Regexp, Match}

pub fn regex(pattern: String) -> Option(Regexp) {
  case pattern |> regexp.from_string {
    Ok(re) -> Some(re)
    _ -> None
  }
}

pub fn matches(str: String, pattern: String) -> List(Match) {
  case pattern |> regex {
    Some(re) -> re |> regexp.scan(str)
    None -> []
  }
}

pub fn match(str: String, pattern: String) -> Match {
  case matches(str, pattern) {
    [match, ..] -> match
    _ -> Match(content: "", submatches: [])
  }
}

pub fn as_int(match: Match) -> Option(Int) {
  match.content |> int.parse |> option.from_result
}

pub fn submatches(str: String, pattern: String) -> List(Option(String)) {
  match(str, pattern).submatches
}

pub fn submatch(str: String, pattern: String) -> Option(String) {
  case match(str, pattern).submatches {
    [Some(first), ..] -> Some(first)
    _ -> None
  }
}

pub fn int_match(str: String) -> Option(Int) {
  match(str, "\\d+") |> as_int
}

pub fn int_matches(str: String) -> List(Int) {
  matches(str, "\\d+")
  |> list.map(as_int)
  |> list.fold(from: [], with: fn(acc, opt) {
    case opt {
      Some(number) -> [number, ..acc]
      _ -> acc
    }
  })
  |> list.reverse
}

pub fn int_submatches(str: String, pattern: String) -> List(Option(Int)) {
  submatches(str, pattern)
  |> list.map(fn(opt) {
    opt
    |> option.map(int.parse)
    |> option.map(option.from_result)
    |> option.flatten
  })
}

pub fn int_submatch(str: String, pattern: String) -> Option(Int) {
  case int_submatches(str, pattern) {
    [Some(value), ..] -> Some(value)
    _ -> None
  }
}
