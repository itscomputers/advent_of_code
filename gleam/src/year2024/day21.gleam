import args.{type Part, PartOne, PartTwo}
import gleam/int
import gleam/list
import gleam/option
import gleam/string

import counter.{type Counter}
import regex
import util

type Counts {
  Counts(code: String, counter: Counter(List(Key)))
}

type Key {
  Zero
  One
  Two
  Three
  Four
  Five
  Six
  Seven
  Eight
  Nine
  Up
  Down
  Left
  Right
  Activate
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> total_complexity(3) |> int.to_string
    PartTwo -> input |> total_complexity(26) |> int.to_string
  }
}

fn total_complexity(input: String, iterations: Int) -> Int {
  input
  |> util.lines
  |> list.map(complexity(_, after: iterations))
  |> int.sum
}

fn length(counts: Counts) -> Int {
  counts.counter
  |> counter.fold(from: 0, with: fn(acc, seq, count) {
    acc + list.length(seq) * count
  })
}

fn value(counts: Counts) -> Int {
  counts.code |> regex.int_match |> option.unwrap(0)
}

fn complexity(code: String, after iterations: Int) -> Int {
  code
  |> initial_counts
  |> iterate(iterations)
  |> fn(c) { length(c) * value(c) }
}

fn loop(seq: List(Key), iterations: Int) -> List(Key) {
  case iterations {
    0 -> seq
    _ -> loop(seq |> get_sequences |> list.flatten, iterations - 1)
  }
}

fn iterate(counts: Counts, iterations: Int) {
  case iterations {
    0 -> counts
    _ -> iterate(counts |> transform, iterations - 1)
  }
}

fn transform(counts: Counts) -> Counts {
  let counter =
    counts.counter
    |> counter.fold(from: counter.new(), with: fn(acc, seq, count) {
      seq
      |> get_sequences
      |> list.fold(from: acc, with: fn(acc, seq) {
        acc |> counter.increment(seq, by: count)
      })
    })
  Counts(..counts, counter:)
}

fn initial_counts(code: String) -> Counts {
  Counts(
    code:,
    counter: counter.new() |> counter.increment(code |> initial_sequence, by: 1),
  )
}

fn get_sequences(sequence: List(Key)) -> List(List(Key)) {
  [Activate, ..sequence]
  |> list.window_by_2
  |> list.map(fn(t) { get_keys(t.0, t.1) })
}

fn initial_sequence(code: String) -> List(Key) {
  code |> string.to_graphemes |> list.map(get_key)
}

fn get_key(ch: String) -> Key {
  case ch {
    "0" -> Zero
    "1" -> One
    "2" -> Two
    "3" -> Three
    "4" -> Four
    "5" -> Five
    "6" -> Six
    "7" -> Seven
    "8" -> Eight
    "9" -> Nine
    "A" -> Activate
    _ -> panic
  }
}

fn get_keys(from: Key, to: Key) -> List(Key) {
  case from {
    Zero ->
      case to {
        Activate -> [Right, Activate]
        Zero -> [Activate]
        One -> [Up, Left, Activate]
        Two -> [Up, Activate]
        Three -> [Up, Right, Activate]
        Four -> [Up, Up, Left, Activate]
        Five -> [Up, Up, Activate]
        Six -> [Up, Up, Right, Activate]
        Seven -> [Up, Up, Up, Left, Activate]
        Eight -> [Up, Up, Up, Activate]
        Nine -> [Up, Up, Up, Right, Activate]
        _ -> panic
      }
    One ->
      case to {
        Activate -> [Right, Right, Down, Activate]
        Zero -> [Right, Down, Activate]
        One -> [Activate]
        Two -> [Right, Activate]
        Three -> [Right, Right, Activate]
        Four -> [Up, Activate]
        Five -> [Up, Right, Activate]
        Six -> [Up, Right, Right, Activate]
        Seven -> [Up, Up, Activate]
        Eight -> [Up, Up, Right, Activate]
        Nine -> [Up, Up, Right, Right, Activate]
        _ -> panic
      }
    Two ->
      case to {
        Activate -> [Down, Right, Activate]
        Zero -> [Down, Activate]
        One -> [Left, Activate]
        Two -> [Activate]
        Three -> [Right, Activate]
        Four -> [Left, Up, Activate]
        Five -> [Up, Activate]
        Six -> [Up, Right, Activate]
        Seven -> [Left, Up, Up, Activate]
        Eight -> [Up, Up, Activate]
        Nine -> [Up, Up, Right, Activate]
        _ -> panic
      }
    Three ->
      case to {
        Activate -> [Down, Activate]
        Zero -> [Left, Down, Activate]
        One -> [Left, Left, Activate]
        Two -> [Left, Activate]
        Three -> [Activate]
        Four -> [Left, Left, Up, Activate]
        Five -> [Left, Up, Activate]
        Six -> [Up, Activate]
        Seven -> [Left, Left, Up, Up, Activate]
        Eight -> [Left, Up, Up, Activate]
        Nine -> [Up, Up, Activate]
        _ -> panic
      }
    Four ->
      case to {
        Activate -> [Right, Right, Down, Down, Activate]
        Zero -> [Right, Down, Down, Activate]
        One -> [Down, Activate]
        Two -> [Down, Right, Activate]
        Three -> [Down, Right, Right, Activate]
        Four -> [Activate]
        Five -> [Right, Activate]
        Six -> [Right, Right, Activate]
        Seven -> [Up, Activate]
        Eight -> [Up, Right, Activate]
        Nine -> [Up, Right, Right, Activate]
        _ -> panic
      }
    Five ->
      case to {
        Activate -> [Down, Down, Right, Activate]
        Zero -> [Down, Down, Activate]
        One -> [Left, Down, Activate]
        Two -> [Down, Activate]
        Three -> [Down, Right, Activate]
        Four -> [Left, Activate]
        Five -> [Activate]
        Six -> [Right, Activate]
        Seven -> [Left, Up, Activate]
        Eight -> [Up, Activate]
        Nine -> [Up, Right, Activate]
        _ -> panic
      }
    Six ->
      case to {
        Activate -> [Down, Down, Activate]
        Zero -> [Left, Down, Down, Activate]
        One -> [Left, Left, Down, Activate]
        Two -> [Left, Down, Activate]
        Three -> [Down, Activate]
        Four -> [Left, Left, Activate]
        Five -> [Left, Activate]
        Six -> [Activate]
        Seven -> [Left, Left, Up, Activate]
        Eight -> [Left, Up, Activate]
        Nine -> [Up, Activate]
        _ -> panic
      }
    Seven ->
      case to {
        Activate -> [Right, Right, Down, Down, Down, Activate]
        Zero -> [Right, Down, Down, Down, Activate]
        One -> [Down, Down, Activate]
        Two -> [Down, Down, Right, Activate]
        Three -> [Down, Down, Right, Right, Activate]
        Four -> [Down, Activate]
        Five -> [Down, Right, Activate]
        Six -> [Down, Right, Right, Activate]
        Seven -> [Activate]
        Eight -> [Right, Activate]
        Nine -> [Right, Right, Activate]
        _ -> panic
      }
    Eight ->
      case to {
        Activate -> [Down, Down, Down, Right, Activate]
        Zero -> [Down, Down, Down, Activate]
        One -> [Left, Down, Down, Activate]
        Two -> [Down, Down, Activate]
        Three -> [Down, Down, Right, Activate]
        Four -> [Left, Down, Activate]
        Five -> [Down, Activate]
        Six -> [Down, Right, Activate]
        Seven -> [Left, Activate]
        Eight -> [Activate]
        Nine -> [Right, Activate]
        _ -> panic
      }
    Nine ->
      case to {
        Activate -> [Down, Down, Down, Activate]
        Zero -> [Left, Down, Down, Down, Activate]
        One -> [Left, Left, Down, Down, Activate]
        Two -> [Left, Down, Down, Activate]
        Three -> [Down, Down, Activate]
        Four -> [Left, Left, Down, Activate]
        Five -> [Left, Down, Activate]
        Six -> [Down, Activate]
        Seven -> [Left, Left, Activate]
        Eight -> [Left, Activate]
        Nine -> [Activate]
        _ -> panic
      }
    Activate ->
      case to {
        Activate -> [Activate]
        Zero -> [Left, Activate]
        One -> [Up, Left, Left, Activate]
        Two -> [Left, Up, Activate]
        Three -> [Up, Activate]
        Four -> [Up, Up, Left, Left, Activate]
        Five -> [Left, Up, Up, Activate]
        Six -> [Up, Up, Activate]
        Seven -> [Up, Up, Up, Left, Left, Activate]
        Eight -> [Left, Up, Up, Up, Activate]
        Nine -> [Up, Up, Up, Activate]
        Up -> [Left, Activate]
        Down -> [Left, Down, Activate]
        Left -> [Down, Left, Left, Activate]
        Right -> [Down, Activate]
      }
    Up ->
      case to {
        Activate -> [Right, Activate]
        Up -> [Activate]
        Down -> [Down, Activate]
        Left -> [Down, Left, Activate]
        Right -> [Down, Right, Activate]
        _ -> panic
      }
    Down ->
      case to {
        Activate -> [Up, Right, Activate]
        Up -> [Up, Activate]
        Down -> [Activate]
        Left -> [Left, Activate]
        Right -> [Right, Activate]
        _ -> panic
      }
    Left ->
      case to {
        Activate -> [Right, Right, Up, Activate]
        Up -> [Right, Up, Activate]
        Down -> [Right, Activate]
        Left -> [Activate]
        Right -> [Right, Right, Activate]
        _ -> panic
      }
    Right ->
      case to {
        Activate -> [Up, Activate]
        Up -> [Left, Up, Activate]
        Down -> [Left, Activate]
        Left -> [Left, Left, Activate]
        Right -> [Activate]
        _ -> panic
      }
  }
}
