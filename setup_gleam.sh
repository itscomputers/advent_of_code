#!/bin/bash

printf -v day "%02d" $2
gleam_file="gleam/src/year${1}/day${day}.gleam"
gleam_code="import args.{type Part, PartOne, PartTwo}
import gleam/list

import util

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> \"0\"
    PartTwo -> \"0\"
  }
}"

test_file="gleam/test/year${1}/day${day}_test.gleam"
test_code="import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year${1}/day${day}

const example = \"\"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day${day}.main(PartOne) |> should.equal(\"0\")
}

pub fn part_two_test() {
  example |> day${day}.main(PartTwo) |> should.equal(\"0\")
}"

mkdir -p "inputs/year$"
mkdir -p "gleam/src/year${1}"
mkdir -p "gleam/test/year${1}"

if [ ! -f "${gleam_file}" ]; then
  echo "creating src and test for year${1}/day${day}"

  touch $gleam_file
  echo "$gleam_code" > $gleam_file

  touch $test_file
  echo "$test_code" > $test_file
fi

