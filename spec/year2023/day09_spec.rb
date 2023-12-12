require "year2023/day09"

describe Year2023::Day09 do
  let(:day) { Year2023::Day09.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      0 3 6 9 12 15
      1 3 6 10 15 21
      10 13 16 21 30 45
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 114 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 2 }
  end
end
