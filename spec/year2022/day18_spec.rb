require "year2022/day18"

describe Year2022::Day18 do
  let(:day) { Year2022::Day18.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      2,2,2
      1,2,2
      3,2,2
      2,1,2
      2,3,2
      2,2,1
      2,2,3
      2,2,4
      2,2,6
      1,2,5
      3,2,5
      2,1,5
      2,3,5
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 64 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 58 }
  end
end
