import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}
import gleam/string
import gleam/string_tree

pub opaque type Counter(a) {
  Counter(inner: Dict(a, Int))
}

pub fn new() -> Counter(a) {
  Counter(inner: dict.new())
}

pub fn from_list(lst: List(a)) -> Counter(a) {
  Counter(
    inner: lst
    |> list.fold(from: dict.new(), with: fn(acc, key) {
      increment_inner(acc, key, 1)
    }),
  )
}

pub fn size(counter: Counter(a)) -> Int {
  counter.inner |> dict.size
}

pub fn is_empty(counter: Counter(a)) -> Bool {
  counter.inner |> dict.is_empty
}

pub fn to_string(counter: Counter(a)) -> String {
  counter
  |> fold(from: string_tree.from_string("{\n"), with: fn(acc, key, count) {
    acc
    |> string_tree.append("  ")
    |> string_tree.append(string.inspect(key))
    |> string_tree.append(": ")
    |> string_tree.append(int.to_string(count))
    |> string_tree.append(",\n")
  })
  |> string_tree.append("}")
  |> string_tree.to_string
}

pub fn display(counter: Counter(a)) -> Counter(a) {
  counter |> to_string |> string.split("\n") |> list.each(io.println)
  counter
}

pub fn get(counter: Counter(a), key: a) -> Int {
  counter.inner |> get_inner(key)
}

pub fn prune(counter: Counter(a)) -> Counter(a) {
  Counter(inner: counter.inner |> dict.filter(fn(_, count) { count > 0 }))
}

pub fn increment(counter: Counter(a), key: a, by value: Int) -> Counter(a) {
  Counter(inner: counter.inner |> increment_inner(key, value))
}

pub fn decrement(counter: Counter(a), key: a, by value: Int) -> Counter(a) {
  Counter(inner: counter.inner |> decrement_inner(key, value))
}

pub fn combine(counter: Counter(a), other: Counter(a)) -> Counter(a) {
  Counter(inner: counter.inner |> dict.combine(other.inner, int.add))
}

pub fn delete(from counter: Counter(a), delete key: a) -> Counter(a) {
  Counter(inner: counter.inner |> dict.delete(key))
}

pub fn drop(from counter: Counter(a), drop dropped_keys: List(a)) -> Counter(a) {
  Counter(inner: counter.inner |> dict.drop(dropped_keys))
}

pub fn each(counter: Counter(a), func: fn(a, Int) -> c) -> Nil {
  counter.inner |> dict.each(func)
}

pub fn filter(
  in counter: Counter(a),
  keeping predicate: fn(a, Int) -> Bool,
) -> Counter(a) {
  Counter(inner: counter.inner |> dict.filter(predicate))
}

pub fn fold(
  over counter: Counter(a),
  from initial: c,
  with func: fn(c, a, Int) -> c,
) -> c {
  counter.inner |> dict.fold(initial, func)
}

pub fn keys(counter: Counter(a)) -> List(a) {
  counter.inner |> dict.keys
}

pub fn key_set(counter: Counter(a)) -> Set(a) {
  counter.inner |> dict.keys |> set.from_list
}

pub fn values(counter: Counter(a)) -> List(Int) {
  counter.inner |> dict.values
}

pub fn has_key(counter: Counter(a), key: a) -> Bool {
  counter.inner |> dict.has_key(key)
}

pub fn take(from counter: Counter(a), keeping kept_keys: List(a)) -> Counter(a) {
  Counter(inner: counter.inner |> dict.take(kept_keys))
}

pub fn to_list(counter: Counter(a)) -> List(#(a, Int)) {
  counter.inner |> dict.to_list
}

fn get_inner(inner: Dict(a, Int), key: a) -> Int {
  case inner |> dict.get(key) {
    Ok(count) -> count
    Error(_) -> 0
  }
}

fn increment_inner(inner: Dict(a, Int), key: a, value: Int) -> Dict(a, Int) {
  inner |> dict.insert(key, get_inner(inner, key) + value)
}

fn decrement_inner(inner: Dict(a, Int), key: a, value: Int) -> Dict(a, Int) {
  case inner |> dict.get(key) {
    Ok(curr) if curr <= value -> inner |> dict.delete(key)
    Ok(count) -> inner |> dict.insert(key, count - value)
    Error(_) -> inner
  }
}
