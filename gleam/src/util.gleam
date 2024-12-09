import gleam/io
import gleam/list
import gleam/otp/task
import gleam/string

pub fn debug(value: a, prefix: String) -> a {
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

fn split(input: String, delimiter: String) -> List(String) {
  input |> string.split(delimiter) |> filter_out_empty
}

fn filter_out_empty(strings: List(String)) -> List(String) {
  strings |> list.filter(fn(str) { !string.is_empty(str) })
}
