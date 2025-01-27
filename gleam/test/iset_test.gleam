import gleam/list
import gleeunit
import gleeunit/should

import iset.{type ISet}

pub fn main() {
  gleeunit.main()
}

pub fn new_test() {
  iset.new()
  |> assert_contains([])
  |> iset.is_empty
  |> should.be_true
}

pub fn from_list_test() {
  let values = [1, 5, 3, 62, 5, 4, 3]
  iset.from_list(values)
  |> assert_contains(values)
}

pub fn to_list_test() {
  [1, 5, 3, 62, 5, 4, 3]
  |> iset.from_list
  |> iset.to_list
  |> should.equal([1, 3, 4, 5, 62])
}

pub fn few_test() {
  iset.new()
  |> iset.insert(5)
  |> iset.insert(29)
  |> iset.insert(16)
  |> assert_contains([5, 16, 29])
}

pub fn insert_test() {
  [20, 30, 40]
  |> iset.from_list
  |> assert_contains([20, 30, 40])
  |> iset.insert(33)
  |> assert_contains([20, 30, 33, 40])
}

pub fn insert_existing_test() {
  [20, 30, 40]
  |> iset.from_list
  |> assert_contains([20, 30, 40])
  |> iset.insert(30)
  |> assert_contains([20, 30, 40])
}

pub fn delete_test() {
  [20, 30, 40]
  |> iset.from_list
  |> assert_contains([20, 30, 40])
  |> iset.delete(30)
  |> assert_contains([20, 40])
}

pub fn delete_absent_test() {
  [20, 30, 40]
  |> iset.from_list
  |> assert_contains([20, 30, 40])
  |> iset.delete(33)
  |> assert_contains([20, 30, 40])
}

pub fn delete_all_test() {
  [20, 30, 40]
  |> iset.from_list
  |> assert_contains([20, 30, 40])
  |> iset.delete(20)
  |> assert_contains([30, 40])
  |> iset.delete(30)
  |> assert_contains([40])
  |> iset.delete(40)
  |> assert_contains([])
  |> iset.is_empty
  |> should.be_true
}

fn assert_contains(set: ISet, values: List(Int)) -> ISet {
  list.range(0, 63)
  |> list.each(fn(value) {
    set |> iset.contains(value) |> should.equal(list.contains(values, value))
  })
  set |> iset.size |> should.equal(values |> list.unique |> list.length)
  set
}
