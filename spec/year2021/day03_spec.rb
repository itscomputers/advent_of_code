require "year2021/day03"

describe Year2021::Day03 do
  let(:day) { Year2021::Day03.new }
  before do
    allow(day).to receive(:lines).and_return [
      "00100",
      "11110",
      "10110",
      "10111",
      "10101",
      "01111",
      "00111",
      "11100",
      "10000",
      "11001",
      "00010",
      "01010",
    ]
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 198 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 230 }
  end
end
