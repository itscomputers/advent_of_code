import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/string

import util

type Operation {
  And(a: String, b: String, output: String)
  Or(a: String, b: String, output: String)
  Xor(a: String, b: String, output: String)
}

type Network {
  Network(
    inputs: Dict(String, Int),
    now: List(Operation),
    later: List(Operation),
    x: List(String),
    y: List(String),
    outputs: List(String),
  )
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> build_network |> loop |> output |> int.to_string
    PartTwo -> input |> build_network |> find_swaps |> string.join(",")
  }
}

fn build_network(input: String) -> Network {
  let assert [input_str, op_str] = input |> util.blocks
  let inputs =
    input_str
    |> util.lines
    |> list.fold(from: dict.new(), with: add_input)
  let later = op_str |> util.lines |> list.map(build_operation)
  Network(inputs:, now: [], later:, x: [], y: [], outputs: [])
  |> set_inputs
  |> set_outputs
  |> update_ready
}

fn output(network: Network) -> Int {
  network |> get_number(network.outputs)
}

fn loop(network: Network) -> Network {
  case network.now {
    [] -> network
    [operation, ..now] ->
      Network(..network, now:)
      |> handle(operation)
      |> loop
  }
}

fn handle(network: Network, operation: Operation) -> Network {
  let a = network |> get_value(operation.a)
  let b = network |> get_value(operation.b)
  let op = case operation {
    And(..) -> int.bitwise_and
    Or(..) -> int.bitwise_or
    Xor(..) -> int.bitwise_exclusive_or
  }
  let inputs = network.inputs |> dict.insert(operation.output, op(a, b))
  Network(..network, inputs:)
  |> update_ready
}

fn update_ready(network: Network) -> Network {
  let #(now, later) =
    network.later |> list.partition(is_ready(network.inputs, _))
  let now = list.append(network.now, now)
  Network(..network, now:, later:)
}

fn set_inputs(network: Network) -> Network {
  let inputs_for = fn(ch) {
    network.later
    |> list.flat_map(fn(operation) { [operation.a, operation.b] })
    |> list.filter(fn(input) { input |> string.starts_with(ch) })
    |> list.unique
    |> list.sort(by: string.compare)
  }
  let x = inputs_for("x")
  let y = inputs_for("y")
  Network(..network, x:, y:)
}

fn set_outputs(network: Network) -> Network {
  let outputs =
    network.later
    |> list.map(fn(operation) { operation.output })
    |> list.filter(fn(output) { output |> string.starts_with("z") })
    |> list.sort(by: string.compare)
  Network(..network, outputs:)
}

fn add_input(inputs: Dict(String, Int), line: String) -> Dict(String, Int) {
  let assert [var, value] = line |> string.split(": ")
  case value {
    "1" -> inputs |> dict.insert(var, 1)
    _ -> inputs |> dict.insert(var, 0)
  }
}

fn build_operation(line: String) -> Operation {
  let assert [a, op, b, _, output] = line |> string.split(" ")
  case op {
    "AND" -> And(a:, b:, output:)
    "OR" -> Or(a:, b:, output:)
    "XOR" -> Xor(a:, b:, output:)
    _ -> panic
  }
}

fn is_ready(inputs: Dict(String, Int), operation: Operation) -> Bool {
  [operation.a, operation.b] |> list.all(dict.has_key(inputs, _))
}

fn get_value(network: Network, key: String) -> Int {
  case network.inputs |> dict.get(key) {
    Ok(value) -> value
    Error(_) -> -1
  }
}

fn get_number(network: Network, vars: List(String)) -> Int {
  case
    vars
    |> list.map(get_value(network, _))
    |> list.reverse
    |> int.undigits(2)
  {
    Ok(output) -> output
    Error(_) -> 0
  }
}

fn find_swaps(network: Network) -> List(String) {
  let lookup =
    network.now
    |> list.append(network.later)
    |> list.map(fn(operation) { #(operation.output, operation) })
    |> dict.from_list

  let is_xor = fn(op: Operation) {
    case op {
      Xor(..) -> True
      _ -> False
    }
  }

  let index = fn(var: String) { var |> string.drop_start(1) }

  let has_inner_xor = fn(op: Operation, matching: String) -> Bool {
    list.any([op.a, op.b], fn(sub) {
      case lookup |> dict.get(sub) {
        Ok(Xor(a, b, _)) ->
          list.any([a, b], fn(sub) { index(sub) == index(matching) })
        _ -> False
      }
    })
  }

  let has_xor = fn(op: Operation, matching: String) {
    is_xor(op) && has_inner_xor(op, matching)
  }

  let find_xor = fn(matching: String) {
    case
      lookup
      |> dict.filter(fn(_, op) { has_xor(op, matching) })
      |> dict.keys
      |> list.first
    {
      Ok(var) -> var
      Error(_) -> panic
    }
  }

  let find_inner_xor = fn(matching: String) {
    case
      lookup
      |> dict.filter(fn(_, op) { is_xor(op) && index(op.a) == index(matching) })
      |> dict.keys
      |> list.first
    {
      Ok(var) -> var
      Error(_) -> panic
    }
  }

  let needs_xor =
    lookup
    |> dict.take(network.outputs)
    |> dict.filter(fn(var, op) { var != "z45" && !is_xor(op) })
    |> dict.keys
    |> list.flat_map(fn(var) { [var, find_xor(var)] })

  let needs_inner_xor =
    lookup
    |> dict.take(network.outputs)
    |> dict.filter(fn(var, op) {
      var != "z45" && var != "z00" && is_xor(op) && !has_inner_xor(op, var)
    })
    |> dict.fold(from: [], with: fn(acc, var, op) {
      let assert Ok(sub_op) =
        [op.a, op.b]
        |> list.map(dict.get(lookup, _))
        |> list.find(fn(res) {
          case res {
            Ok(And(..)) -> True
            _ -> False
          }
        })
        |> result.flatten
      acc |> list.append([sub_op.output, find_inner_xor(var)])
    })

  needs_xor
  |> list.append(needs_inner_xor)
  |> list.sort(by: string.compare)
}
