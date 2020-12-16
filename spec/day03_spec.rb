require 'advent/day03'

describe Advent::Day03 do
  let(:day) { described_class.new(input, slopes: slopes) }
  let(:slopes) { [] }
  let(:raw_input) { [
    "..#.",
    ".#..",
    "#..#",
    ".#.#",
    "..#.",
    ".#..",
    "#..#",
    ".#.#",
  ].join("\n") }

  let(:trees) do
    Set.new(
      [
        [2, 0],
        [1, 1],
        [0, 2], [3, 2],
        [1, 3], [3, 3],
        [2, 4],
        [1, 5],
        [0, 6], [3, 6],
        [1, 7], [3, 7],
      ].map { |(x, y)| Point.new(x, y) }
    )
  end

  let(:input) { { :size => Point.new(4, 8), :trees => trees } }

  describe '.sanitized_input' do
    subject { described_class.sanitized_input }
    before { allow(described_class).to receive(:raw_input).and_return raw_input }
    it { is_expected.to eq input }
  end

  describe '#tree count' do
    subject { day.tree_count(slope) }

    context "when slope is 2/1" do
      let(:slope) { Point.new(1, 2) }
      <<~AREA
        ..#...#...#...#...#.
        .#...#...#...#...#..
        #o.##..##..##..##..#
        .#.#.#.#.#.#.#.#.#.#
        ..x...#...#...#...#.
        .#...#...#...#...#..
        #..##..##..##..##..#
        .#.#.#.#.#.#.#.#.#.#
      AREA

      it { is_expected.to eq 2 }
    end

    context "when slope is 1/2" do
      let(:slope) { Point.new(2, 1) }
      <<~AREA
        ..#...#...#...#...#.
        .#o..#...#...#...#..
        #..#x..##..##..##..#
        .#.#.#o#.#.#.#.#.#.#
        ..#...#.o.#...#...#.
        .#...#...#o..#...#..
        #...#..##..#x..##..#
        .#.#.#.#.#.#.#o#.#.#
      AREA

      it { is_expected.to eq 2 }
    end

    context "when slope is 2/3" do
      let(:slope) { Point.new(3, 2) }
      <<~AREA
        ..#...#...#...#...#.
        .#...#...#...#...#..
        #..x#..##..##..##..#
        .#.#.#.#.#.#.#.#.#.#
        ..#...x...#...#...#.
        .#...#...#...#...#..
        #...#..##o.##..##..#
        .#.#.#.#.#.#.#.#.#.#
      AREA

      it { is_expected.to eq 2 }
    end
  end
end
