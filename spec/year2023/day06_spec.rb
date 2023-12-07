require "year2023/day06"

describe Year2023::Day06 do
  let(:day) { Year2023::Day06.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Time:      7  15   30
      Distance:  9  40  200
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 288 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 71503 }
  end
end
