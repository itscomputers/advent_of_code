require "year2022/day04"

describe Year2022::Day04 do
  let(:day) { Year2022::Day04.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      2-4,6-8
      2-3,4-5
      5-7,7-9
      2-8,3-7
      6-6,4-6
      2-6,4-8
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 2 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 4 }
  end
end
