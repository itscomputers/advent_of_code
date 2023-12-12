require "year2023/day11"

describe Year2023::Day11 do
  let(:day) { Year2023::Day11.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      ...#......
      .......#..
      #.........
      ..........
      ......#...
      .#........
      .........#
      ..........
      .......#..
      #...#.....
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 374 }
  end

  describe "part 2" do
    subject { day.galaxies(factor: factor).distances.sum }

    context "when factor is 10" do
      let(:factor) { 10 }
      it { is_expected.to eq 1030 }
    end

    context "when factor is 100" do
      let(:factor) { 100 }
      it { is_expected.to eq 8410 }
    end
  end
end
