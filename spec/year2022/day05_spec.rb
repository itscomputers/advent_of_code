require "year2022/day05"

describe Year2022::Day05 do
  let(:day) { Year2022::Day05.new }
  let(:part) { 1 }
  let(:cargo_crane) { day.cargo_crane(part: part) }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          [D]
      [N] [C]
      [Z] [M] [P]
       1   2   3

      move 1 from 2 to 1
      move 3 from 1 to 3
      move 2 from 2 to 1
      move 1 from 1 to 2
    RAW_INPUT
  end

  describe "stacks" do
    subject { cargo_crane.stacks.map(&:crates) }
    it { is_expected.to eq [%w(Z N), %w(M C D), %w(P)] }
  end

  describe "moves" do
    subject { cargo_crane.moves.map { |move| [move.count, move.source, move.target] } }
    it { is_expected.to eq [
      [1, 2, 1],
      [3, 1, 3],
      [2, 2, 1],
      [1, 1, 2],
    ] }
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq "CMZ" }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq "MCD" }
  end
end
