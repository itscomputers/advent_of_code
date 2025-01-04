import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/function
import gleam/int
import gleam/list
import gleam/otp/task
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
    PartTwo -> input |> build_network |> swaps |> dict.size |> int.to_string
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

fn swaps(network: Network) -> Dict(#(Operation, Operation), Int) {
  list.append(network.now, network.later)
  |> list.combination_pairs
  |> list.map(fn(swap) {
    task.async(fn() {
      let n = network |> do_swap([swap]) |> loop
      #(swap, expected_output(n) - output(n))
    })
  })
  |> list.map(task.await_forever)
  |> dict.from_list
  |> function.tap(fn(d) {
    dict.each(d, fn(s, diff) {
      util.println(diff, { s.0 }.output <> "--" <> { s.1 }.output)
    })
  })
}

fn expected_output(network: Network) -> Int {
  get_number(network, network.x) + get_number(network, network.y)
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

fn do_swap(network: Network, swap: List(#(Operation, Operation))) -> Network {
  let operations =
    network.now
    |> list.append(network.later)
    |> list.filter(fn(op) { swap |> list.all(fn(t) { op != t.0 && op != t.1 }) })
  let swapped =
    swap
    |> list.flat_map(fn(t) {
      [reset_output(t.0, { t.1 }.output), reset_output(t.1, { t.0 }.output)]
    })
  let later = list.append(operations, swapped)
  Network(..network, now: [], later:) |> update_ready
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

fn reset_output(operation: Operation, output: String) -> Operation {
  case operation {
    And(..) -> And(..operation, output:)
    Or(..) -> Or(..operation, output:)
    Xor(..) -> Xor(..operation, output:)
  }
}
