import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/set
import regex

import args.{type Part, PartOne, PartTwo}
import counter.{type Counter}
import util

pub type Secret {
  Secret(
    number: Int,
    price: Int,
    change: List(Int),
    changes: Counter(List(Int)),
  )
}

pub type Change {
  Empty
  One(c0: Int)
  Two(c0: Int, c1: Int)
  Three(c0: Int, c1: Int, c2: Int)
  Four(c0: Int, c1: Int, c2: Int, c3: Int)
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> sum |> int.to_string
    PartTwo -> input |> banana_count |> int.to_string
  }
}

fn sum(input: String) -> Int {
  input
  |> build_secrets
  |> list.fold(from: 0, with: fn(acc, secret) { acc + secret.number })
}

fn banana_count(input: String) -> Int {
  let secrets = input |> build_secrets
  secrets
  |> list.fold(from: set.new(), with: fn(acc, secret) {
    acc |> set.union(secret.changes |> counter.key_set)
  })
  |> set.fold(from: 0, with: fn(acc, change) {
    secrets
    |> list.fold(from: 0, with: fn(acc, secret) {
      acc + counter.get(secret.changes, change)
    })
    |> int.max(acc)
  })
}

fn build_secrets(input: String) -> List(Secret) {
  input
  |> util.lines
  |> list.map(secret)
  |> list.map(iterate(_, 2000))
}

pub fn secret(input: String) -> Secret {
  let assert Some(number) = input |> regex.int_match
  Secret(number:, price: 0, change: [], changes: counter.new())
}

fn iterate(secret: Secret, iterations: Int) -> Secret {
  case iterations {
    0 -> secret
    _ -> secret |> next |> iterate(iterations - 1)
  }
}

fn mix(secret: Secret, value: Int) -> Secret {
  Secret(..secret, number: secret.number |> int.bitwise_exclusive_or(value))
}

fn prune(secret: Secret) -> Secret {
  Secret(..secret, number: secret.number % 16_777_216)
}

pub fn next(secret: Secret) -> Secret {
  secret
  |> store_price
  |> perform(int.multiply, with: 64)
  |> perform(divide, with: 32)
  |> perform(int.multiply, with: 2048)
  |> record_change
}

fn store_price(secret: Secret) -> Secret {
  Secret(..secret, price: secret |> price)
}

fn record_change(secret: Secret) -> Secret {
  let diff = price(secret) - secret.price
  let change = [diff, ..secret.change] |> list.take(4)
  let changes = case
    list.length(change),
    counter.has_key(secret.changes, change)
  {
    4, False -> secret.changes |> counter.increment(change, by: secret |> price)
    _, _ -> secret.changes
  }
  Secret(..secret, change:, changes:)
}

fn price(secret: Secret) -> Int {
  secret.number % 10
}

fn perform(secret: Secret, op: fn(Int, Int) -> Int, with value: Int) -> Secret {
  secret
  |> mix(op(secret.number, value))
  |> prune
}

fn divide(a: Int, b: Int) -> Int {
  a / b
}
