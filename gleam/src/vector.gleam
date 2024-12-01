import gleam/int
import gleam/list

pub fn add(vector: List(Int), other: List(Int)) -> List(Int) {
  vector
  |> list.zip(other)
  |> list.map(fn(tuple) { tuple.0 + tuple.1 })
}

pub fn negate(vector: List(Int)) -> List(Int) {
  vector |> list.map(int.negate)
}

pub fn subtract(vector: List(Int), other: List(Int)) -> List(Int) {
  vector |> add(other |> negate)
}

pub fn dot(vector: List(Int), other: List(Int)) -> Int {
  vector
  |> list.zip(other)
  |> list.map(fn(tuple) { tuple.0 * tuple.1 })
  |> int.sum
}

pub fn norm(vector: List(Int)) -> Int {
  vector
  |> list.map(int.absolute_value)
  |> int.sum
}

pub fn distance(vector: List(Int), other: List(Int)) -> Int {
  vector
  |> subtract(other)
  |> norm
}

pub fn scale(vector: List(Int), scalar: Int) -> List(Int) {
  vector |> list.map(int.multiply(_, scalar))
}
