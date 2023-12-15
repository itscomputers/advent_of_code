require "year2023/day13"

describe Year2023::Day13 do
  let(:day) { Year2023::Day13.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      #.##..##.
      ..#.##.#.
      ##......#
      ##......#
      ..#.##.#.
      ..##..##.
      #.#.##.#.

      #...##..#
      #....#..#
      ..##..###
      #####.##.
      #####.##.
      ..##..###
      #....#..#
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 405 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 400 }
  end
end
