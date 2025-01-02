import gleam/dict.{type Dict}
import gleam/int
import gleam/io
import gleam/list
import gleam/pair
import gleam/string

import args.{type Part, PartOne, PartTwo}
import regex
import util

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne ->
      input
      |> from_str
      |> run(Normal)
      |> output
      |> list.map(int.to_string)
      |> string.join(",")
    PartTwo -> {
      let a = 190_615_597_431_823
      // input
      // |> from_str
      // |> reset(a)
      // |> run(Normal)
      // |> output
      a |> int.to_string
    }
  }
}

pub opaque type IntComputer {
  IntComputer(
    program: Dict(Int, Int),
    ptr: Int,
    reg: Dict(Register, Int),
    out: List(Int),
    status: Status,
  )
}

type Operand {
  Literal
  Combo
}

pub type Register {
  A
  B
  C
}

pub type Mode {
  Normal
  Debug
}

type Status {
  Continue
  Halt
}

fn from_str(input: String) -> IntComputer {
  let assert [reg_str, prog_str] = input |> util.blocks
  let assert [a, b, c] = reg_str |> regex.int_matches
  let program = prog_str |> regex.int_matches
  cmp(program, a, b, c)
}

pub fn cmp(program: List(Int), a: Int, b: Int, c: Int) -> IntComputer {
  IntComputer(
    program: program |> list.index_map(fn(x, i) { #(i, x) }) |> dict.from_list,
    ptr: 0,
    reg: [#(A, a), #(B, b), #(C, c)] |> dict.from_list,
    out: [],
    status: Continue,
  )
}

pub fn output(cmp: IntComputer) -> List(Int) {
  cmp.out |> list.reverse
}

pub fn run(cmp: IntComputer, mode: Mode) -> IntComputer {
  cmp |> display(mode == Debug)
  case cmp.status {
    Halt -> cmp
    Continue -> {
      case
        cmp.program |> dict.get(cmp.ptr),
        cmp.program |> dict.get(cmp.ptr + 1)
      {
        Ok(opcode), Ok(operand) ->
          instruction(opcode)(cmp, operand) |> run(mode)
        _, _ -> IntComputer(..cmp, status: Halt)
      }
    }
  }
}

// fn reset(cmp: IntComputer, a: Int) -> IntComputer {
//   IntComputer(..cmp, ptr: 0, out: [], status: Continue)
//   |> set(A, a)
//   |> set(B, 0)
//   |> set(C, 0)
// }

fn value(cmp: IntComputer, op: Int, operand: Operand) -> Int {
  case operand {
    Literal -> op
    Combo ->
      case op {
        0 | 1 | 2 | 3 -> op
        4 -> get(cmp, A)
        5 -> get(cmp, B)
        6 -> get(cmp, C)
        _ -> panic
      }
  }
}

fn instruction(opcode: Int) -> fn(IntComputer, Int) -> IntComputer {
  case opcode {
    0 -> adv
    1 -> bxl
    2 -> bst
    3 -> jnz
    4 -> bxc
    5 -> out
    6 -> bdv
    7 -> cdv
    _ -> panic
  }
}

pub fn get(cmp: IntComputer, register: Register) -> Int {
  case cmp.reg |> dict.get(register) {
    Ok(value) -> value
    Error(_) -> panic
  }
}

fn adv(cmp: IntComputer, op: Int) -> IntComputer {
  cmp |> dv(A, op)
}

fn bxl(cmp: IntComputer, op: Int) -> IntComputer {
  cmp
  |> set(B, int.bitwise_exclusive_or(get(cmp, B), value(cmp, op, Literal)))
  |> inc
}

fn bst(cmp: IntComputer, op: Int) -> IntComputer {
  cmp
  |> set(B, value(cmp, op, Combo) % 8)
  |> inc
}

fn jnz(cmp: IntComputer, op: Int) -> IntComputer {
  case get(cmp, A) == 0 {
    True -> cmp |> inc
    False -> cmp |> jmp(to: value(cmp, op, Literal))
  }
}

fn bxc(cmp: IntComputer, _op: Int) -> IntComputer {
  cmp |> set(B, int.bitwise_exclusive_or(get(cmp, B), get(cmp, C))) |> inc
}

fn out(cmp: IntComputer, op: Int) -> IntComputer {
  let out = [value(cmp, op, Combo) % 8, ..cmp.out]
  IntComputer(..cmp, out:) |> inc
}

fn bdv(cmp: IntComputer, op: Int) -> IntComputer {
  cmp |> dv(B, op)
}

fn cdv(cmp: IntComputer, op: Int) -> IntComputer {
  cmp |> dv(C, op)
}

fn dv(cmp: IntComputer, register: Register, op: Int) -> IntComputer {
  cmp |> set(register, div2(get(cmp, A), value(cmp, op, Combo))) |> inc
}

fn set(cmp: IntComputer, register: Register, value: Int) -> IntComputer {
  let reg = cmp.reg |> dict.insert(register, value)
  IntComputer(..cmp, reg:)
}

fn jmp(cmp: IntComputer, to ptr: Int) -> IntComputer {
  IntComputer(..cmp, ptr:)
}

fn inc(cmp: IntComputer) -> IntComputer {
  cmp |> jmp(to: cmp.ptr + 2)
}

fn div2(number: Int, exp: Int) -> Int {
  case exp {
    0 -> number
    e -> div2(number / 2, e - 1)
  }
}

fn program(cmp: IntComputer) -> List(Int) {
  cmp.program
  |> dict.to_list
  |> list.sort(by: fn(t1, t2) { int.compare(t1.0, t2.0) })
  |> list.map(pair.second)
}

fn match_count(cmp: IntComputer, count: Int) -> Int {
  case
    cmp |> program |> list.take(count + 1)
    == cmp |> output |> list.take(count + 1)
  {
    True -> match_count(cmp, count + 1)
    False -> count
  }
}

fn display(cmp: IntComputer, show: Bool) -> IntComputer {
  case show {
    False -> Nil
    True -> {
      io.println("")
      io.println(
        {
          cmp
          |> program
          |> list.map(int.to_string)
          |> string.join(",")
        }
        <> "    A="
        <> int.to_string(get(cmp, A))
        <> "    B="
        <> int.to_string(get(cmp, B))
        <> "    C="
        <> int.to_string(get(cmp, C))
        <> "    out="
        <> { cmp |> output |> list.map(int.to_string) |> string.join(",") }
        <> "    status="
        <> string.inspect(cmp.status),
      )
      io.println(string.repeat(" ", cmp.ptr * 2) <> "|")
    }
  }
  cmp
}
