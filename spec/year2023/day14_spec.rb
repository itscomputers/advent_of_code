require "year2023/day14"

describe Year2023::Day14 do
  let(:day) { Year2023::Day14.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      O....#....
      O.OO#....#
      .....##...
      OO.#O....O
      .O.....O#.
      O.#..O.#.#
      ..O..#O..O
      .......O..
      #....###..
      #OO..#....
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 136 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 64 }
  end
end
