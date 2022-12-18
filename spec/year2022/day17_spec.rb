require "year2022/day17"

describe Year2022::Day17 do
  let(:day) { Year2022::Day17.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      >>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>
    RAW_INPUT
    allow(day).to receive(:offset).and_return 15
    allow(day).to receive(:period).and_return 35
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 3068 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 1514285714288 }
  end

  describe "height after first 10" do
    let(:tetris) { described_class::Tetris.new(day.shapes, day.gusts) }
    subject { tetris.handle_pieces(count: 10).height }
    it { is_expected.to eq 17 }
  end
end
