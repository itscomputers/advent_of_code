import gleam/dict.{type Dict}
import gleam/int
import gleam/list

pub opaque type Counter(a) {
  Counter(inner: Dict(a, Int))
}

pub fn from_list(lst: List(a)) -> Counter(a) {
  Counter(inner: lst |> list.fold(from: dict.new(), with: increment_inner))
}

pub fn get(counter: Counter(a), key: a) -> Int {
  counter.inner |> get_inner(key)
}

pub fn increment(counter: Counter(a), key: a) -> Counter(a) {
  Counter(inner: counter.inner |> increment_inner(key))
}

pub fn decrement(counter: Counter(a), key: a) -> Counter(a) {
  Counter(inner: counter.inner |> decrement_inner(key))
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

fn increment_inner(inner: Dict(a, Int), key: a) -> Dict(a, Int) {
  case inner |> dict.get(key) {
    Ok(count) -> inner |> dict.insert(key, count + 1)
    Error(_) -> inner |> dict.insert(key, 1)
  }
}

fn decrement_inner(inner: Dict(a, Int), key: a) -> Dict(a, Int) {
  case inner |> dict.get(key) {
    Ok(1) -> inner |> dict.delete(key)
    Ok(count) -> inner |> dict.insert(key, count - 1)
    Error(_) -> inner
  }
}
