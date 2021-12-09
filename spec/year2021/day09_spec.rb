require "year2021/day09"

describe Year2021::Day09 do
  let(:day) { Year2021::Day09.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW
      2199943210
      3987894921
      9856789892
      8767896789
      9899965678
    RAW
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 15 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 1134 }
  end
end

