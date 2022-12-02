require "year2022/day01"

describe Year2022::Day01 do
  let(:day) { Year2022::Day01.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      1000
      2000
      3000

      4000

      5000
      6000

      7000
      8000
      9000

      10000
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 24000 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 45000 }
  end
end
