require "year2022/day12"

describe Year2022::Day12 do
 let(:day) { Year2022::Day12.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Sabqponm
      abcryxxl
      accszExk
      acctuvwj
      abdefghi
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 31 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 29 }
  end
end
