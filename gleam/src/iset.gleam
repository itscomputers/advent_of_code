import gleam/int
import gleam/list

pub opaque type ISet {
  ISet(set: Int, size: Int)
}

pub fn new() -> ISet {
  ISet(set: 0, size: 0)
}

pub fn from_list(ints: List(Int)) -> ISet {
  ints |> list.fold(from: new(), with: insert)
}

pub fn to_list(set: ISet) -> List(Int) {
  list.range(0, 63)
  |> list.filter(contains(set, _))
}

pub fn size(set: ISet) -> Int {
  set.size
}

pub fn is_empty(set: ISet) -> Bool {
  set.size == 0
}

pub fn contains(set: ISet, value: Int) -> Bool {
  set |> contains_(value |> shift)
}

pub fn insert(set: ISet, value: Int) -> ISet {
  let power = shift(value)
  case set |> contains_(power) {
    True -> set
    False -> ISet(set: set |> or(power), size: set.size + 1)
  }
}

pub fn delete(set: ISet, value: Int) -> ISet {
  let power = shift(value)
  let and = set |> and(power)
  case and == power {
    True -> ISet(set: set |> xor(power), size: set.size - 1)
    False -> set
  }
}

fn shift(value: Int) -> Int {
  int.bitwise_shift_left(1, value)
}

fn and(set: ISet, power: Int) -> Int {
  int.bitwise_and(set.set, power)
}

fn xor(set: ISet, power: Int) -> Int {
  int.bitwise_exclusive_or(set.set, power)
}

fn or(set: ISet, power: Int) -> Int {
  int.bitwise_or(set.set, power)
}

fn contains_(set: ISet, power: Int) -> Bool {
  set |> and(power) == power
}
