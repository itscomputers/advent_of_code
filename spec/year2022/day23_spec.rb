require "year2022/day23"

describe Year2022::Day23 do
  let(:day) { Year2022::Day23.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      ....#..
      ..###.#
      #...#.#
      .#...##
      #.###..
      ##.#.##
      .#..#..
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 110 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 20 }
  end
end
