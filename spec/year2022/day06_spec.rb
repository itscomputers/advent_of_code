require "year2022/day06"

describe Year2022::Day06 do
 let(:day) { Year2022::Day06.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      mjqjpqmgbljsphdztnvjfqwrcgsmlb
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 7 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 19 }
  end
end
