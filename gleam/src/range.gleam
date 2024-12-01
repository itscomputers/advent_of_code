import gleam/int
import gleam/list
import gleam/order.{type Order, Eq}

pub type Range {
  Range(lower: Int, upper: Int)
}

pub fn empty() -> Range {
  Range(0, 0)
}

pub fn values(range: Range) -> List(Int) {
  list.range(range.lower, range.upper - 1)
}

pub fn is_empty(range: Range) -> Bool {
  range.lower >= range.upper
}

pub fn contains(range: Range, value: Int) -> Bool {
  range.lower <= value && value < range.upper
}

pub fn size(range: Range) -> Int {
  range.upper - range.lower
}

pub fn compare(range: Range, other: Range) -> Order {
  case int.compare(range.lower, other.lower) {
    Eq -> int.compare(range.upper, other.upper)
    ord -> ord
  }
}

pub fn intersection(range: Range, with other: Range) -> Range {
  Range(
    lower: int.max(range.lower, other.lower),
    upper: int.min(range.upper, other.upper),
  )
}

pub fn subtract(from range: Range, minus other: Range) -> List(Range) {
  case overlaps(range, other) {
    False -> [range]
    True ->
      [
        case range |> contains(other.lower) {
          True -> Range(lower: range.lower, upper: other.lower)
          False -> empty()
        },
        case range |> contains(other.upper) {
          True -> Range(lower: other.upper, upper: range.upper)
          False -> empty()
        },
      ]
      |> list.filter(fn(range) { !is_empty(range) })
  }
}

pub fn overlaps(range: Range, with other: Range) -> Bool {
  range.lower < other.upper && other.lower < range.upper
}

pub fn union(range: Range, with other: Range) -> List(Range) {
  case overlaps(range, other) || adjacent(range, other) {
    True -> [restricted_union_unsafe(range, other)]
    False -> [range, other] |> list.sort(by: compare)
  }
}

pub fn reduce(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.fold(from: [empty()], with: reduce_one)
  |> list.sort(by: compare)
}

fn reduce_one(ranges: List(Range), other: Range) -> List(Range) {
  let #(overlapping, disjoint) =
    ranges
    |> list.partition(fn(range) {
      overlaps(range, other) || adjacent(range, other)
    })
  list.flatten([
    [overlapping |> list.fold(from: other, with: restricted_union_unsafe)],
    disjoint,
  ])
}

pub fn adjacent(range: Range, to other: Range) -> Bool {
  range.upper == other.lower || range.lower == other.upper
}

fn restricted_union_unsafe(range: Range, other: Range) -> Range {
  Range(
    lower: int.min(range.lower, other.lower),
    upper: int.max(range.upper, other.upper),
  )
}
