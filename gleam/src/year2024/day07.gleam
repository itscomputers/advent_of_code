import gleam/int
import gleam/list

import args.{type Part, PartOne, PartTwo}
import regex
import util

type Equation {
  Equation(total: Int, values: List(Int))
}

type Evaluator {
  Evaluator(total: Int, reduced: List(Equation))
}

pub fn main(input: String, part: Part) -> String {
  input |> equations |> calibration(operators(part)) |> int.to_string
}

fn operators(part: Part) -> List(fn(Int, Int) -> Int) {
  case part {
    PartOne -> [int.add, int.multiply]
    PartTwo -> [int.add, int.multiply, int_concat]
  }
}

fn equations(input: String) -> List(Equation) {
  input |> util.lines |> list.map(equation)
}

fn calibration(
  equations: List(Equation),
  operators: List(fn(Int, Int) -> Int),
) -> Int {
  equations
  |> list.map(evaluator)
  |> list.map(fn(ev) { fn() { evaluate(ev, operators) } })
  |> util.run_async
  |> list.filter(success)
  |> list.map(fn(evaluator) { evaluator.total })
  |> int.sum
}

fn equation(line: String) -> Equation {
  case line |> regex.int_matches {
    [total, ..values] -> Equation(total:, values:)
    _ -> panic
  }
}

fn evaluator(equation: Equation) {
  Evaluator(total: equation.total, reduced: [equation])
}

fn success(evaluator: Evaluator) -> Bool {
  evaluator.reduced |> list.any(fn(eq) { eq.total == eq.values |> int.sum })
}

fn evaluate(
  evaluator: Evaluator,
  operators: List(fn(Int, Int) -> Int),
) -> Evaluator {
  case evaluator.reduced |> list.all(fn(eq) { eq.values |> list.length == 1 }) {
    True -> evaluator
    False -> {
      Evaluator(
        ..evaluator,
        reduced: operators
          |> list.flat_map(fn(op) {
            evaluator.reduced
            |> list.map(reduce(_, op))
          }),
      )
      |> evaluate(operators)
    }
  }
}

fn reduce(equation: Equation, operator: fn(Int, Int) -> Int) -> Equation {
  case equation.values {
    [] -> panic
    [_] -> equation
    [first, second, ..values] ->
      Equation(..equation, values: [operator(first, second), ..values])
  }
}

fn int_concat(first: Int, second: Int) -> Int {
  let assert Ok(first_digits) = first |> int.digits(10)
  let assert Ok(second_digits) = second |> int.digits(10)
  let assert Ok(value) =
    list.append(first_digits, second_digits) |> int.undigits(10)
  value
}
