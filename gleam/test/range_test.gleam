import gleam/list
import gleeunit
import gleeunit/should

import range.{Range}

pub fn main() {
  gleeunit.main()
}

pub fn overlaps_test() {
  Range(0, 5) |> range.overlaps(Range(6, 8)) |> should.be_false
  Range(0, 5) |> range.overlaps(Range(5, 8)) |> should.be_false
  Range(0, 5) |> range.overlaps(Range(4, 8)) |> should.be_true
  Range(0, 5) |> range.overlaps(Range(-3, 8)) |> should.be_true
  Range(0, 5) |> range.overlaps(Range(-3, 1)) |> should.be_true
  Range(0, 5) |> range.overlaps(Range(-3, 0)) |> should.be_false
  Range(0, 5) |> range.overlaps(Range(-3, -1)) |> should.be_false
}

pub fn intersection_test() {
  Range(0, 5)
  |> range.intersection(Range(6, 8))
  |> range.is_empty
  |> should.be_true
  Range(0, 5)
  |> range.intersection(Range(5, 8))
  |> range.is_empty
  |> should.be_true
  Range(0, 5) |> range.intersection(Range(4, 8)) |> should.equal(Range(4, 5))
  Range(0, 5) |> range.intersection(Range(2, 3)) |> should.equal(Range(2, 3))
  Range(0, 5) |> range.intersection(Range(2, 2)) |> should.equal(Range(2, 2))
  Range(0, 5) |> range.intersection(Range(-3, 8)) |> should.equal(Range(0, 5))
  Range(0, 5) |> range.intersection(Range(-3, 1)) |> should.equal(Range(0, 1))
  Range(0, 5)
  |> range.intersection(Range(-3, 0))
  |> range.is_empty
  |> should.be_true
  Range(0, 5)
  |> range.intersection(Range(-3, -1))
  |> range.is_empty
  |> should.be_true
}

pub fn union_test() {
  Range(0, 5)
  |> range.union(Range(6, 8))
  |> should.equal([Range(0, 5), Range(6, 8)])
  Range(0, 5) |> range.union(Range(5, 8)) |> should.equal([Range(0, 8)])
  Range(0, 5) |> range.union(Range(4, 8)) |> should.equal([Range(0, 8)])
  Range(0, 5) |> range.union(Range(2, 3)) |> should.equal([Range(0, 5)])
  Range(0, 5) |> range.union(Range(2, 2)) |> should.equal([Range(0, 5)])
  Range(0, 5) |> range.union(Range(-3, 8)) |> should.equal([Range(-3, 8)])
  Range(0, 5) |> range.union(Range(-3, 1)) |> should.equal([Range(-3, 5)])
  Range(0, 5) |> range.union(Range(-3, 0)) |> should.equal([Range(-3, 5)])
  Range(0, 5)
  |> range.union(Range(-3, -1))
  |> should.equal([Range(-3, -1), Range(0, 5)])
}

pub fn subtract_test() {
  Range(0, 5)
  |> range.subtract(Range(6, 8))
  |> should.equal([Range(0, 5)])
  Range(0, 5) |> range.subtract(Range(5, 8)) |> should.equal([Range(0, 5)])
  Range(0, 5) |> range.subtract(Range(4, 8)) |> should.equal([Range(0, 4)])
  Range(0, 5)
  |> range.subtract(Range(-3, 8))
  |> list.is_empty
  |> should.be_true
  Range(0, 5)
  |> range.subtract(Range(2, 3))
  |> should.equal([Range(0, 2), Range(3, 5)])
  Range(0, 5)
  |> range.subtract(Range(2, 2))
  |> should.equal([Range(0, 2), Range(2, 5)])
  Range(0, 5) |> range.subtract(Range(-3, 1)) |> should.equal([Range(1, 5)])
  Range(0, 5) |> range.subtract(Range(-3, 0)) |> should.equal([Range(0, 5)])
  Range(0, 5)
  |> range.subtract(Range(-3, -1))
  |> should.equal([Range(0, 5)])
}

pub fn reduce_test() {
  range.reduce([
    Range(0, 5),
    Range(3, 10),
    Range(2, 6),
    Range(20, 25),
    Range(21, 26),
    Range(22, 27),
    Range(23, 28),
    Range(24, 29),
    Range(25, 30),
    Range(40, 50),
    Range(41, 50),
    Range(41, 49),
    Range(42, 49),
    Range(42, 48),
    Range(43, 48),
    Range(43, 47),
    Range(44, 47),
    Range(44, 46),
    Range(45, 46),
    Range(45, 45),
    Range(60, 65),
    Range(65, 70),
    Range(70, 75),
    Range(75, 80),
  ])
  |> should.equal([Range(0, 10), Range(20, 30), Range(40, 50), Range(60, 80)])
}
