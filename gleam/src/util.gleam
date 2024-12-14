import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/order.{type Order, Gt, Lt}
import gleam/otp/task
import gleam/string

pub fn debug(value: a, prefix: String) -> a {
  io.debug(prefix <> ": " <> string.inspect(value))
  value
}

pub fn println(value: a, prefix: String) -> a {
  io.println(prefix <> ": " <> string.inspect(value))
  value
}

pub fn lines(input: String) -> List(String) {
  input |> split("\n")
}

pub fn blocks(input: String) -> List(String) {
  input |> split("\n\n")
}

pub fn run_async(funcs: List(fn() -> a)) -> List(a) {
  funcs |> list.map(task.async) |> list.map(task.await_forever)
}

pub fn min(values: List(a), by compare: fn(a, a) -> Order) -> Option(a) {
  case values {
    [] -> None
    [value, ..values] -> min_loop(values, value, compare) |> Some
  }
}

fn min_loop(values: List(a), min: a, compare: fn(a, a) -> Order) -> a {
  case values {
    [] -> min
    [value, ..values] ->
      case compare(value, min) {
        Lt -> min_loop(values, value, compare)
        _ -> min_loop(values, min, compare)
      }
  }
}

pub fn max(values: List(a), by compare: fn(a, a) -> Order) -> Option(a) {
  case values {
    [] -> None
    [value, ..values] -> max_loop(values, value, compare) |> Some
  }
}

fn max_loop(values: List(a), max: a, compare: fn(a, a) -> Order) -> a {
  case values {
    [] -> max
    [value, ..values] ->
      case compare(value, max) {
        Gt -> min_loop(values, value, compare)
        _ -> min_loop(values, max, compare)
      }
  }
}

fn split(input: String, delimiter: String) -> List(String) {
  input |> string.split(delimiter) |> filter_out_empty
}

fn filter_out_empty(strings: List(String)) -> List(String) {
  strings |> list.filter(fn(str) { !string.is_empty(str) })
}
