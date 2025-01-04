import gleeunit
import gleeunit/should

import args.{PartOne, PartTwo}
import year2024/day23

const example = "kh-tc
qp-kh
de-cg
ka-co
yn-aq
qp-ub
cg-tb
vc-aq
tb-ka
wh-tc
yn-cg
kh-ub
ta-co
de-co
tc-td
tb-wq
wh-td
ta-ka
td-qp
aq-cg
wq-ub
ub-vc
de-ta
wq-aq
wq-vc
wh-yn
ka-de
kh-ta
co-tc
wh-qp
tb-vc
td-yn"

pub fn main() {
  gleeunit.main()
}

pub fn part_one_test() {
  example |> day23.main(PartOne) |> should.equal("7")
}

pub fn part_two_test() {
  example |> day23.main(PartTwo) |> should.equal("co,de,ka,ta")
}
