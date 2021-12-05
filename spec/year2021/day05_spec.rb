require "year2021/day05"

describe Year2021::Day05 do
  let(:day) { Year2021::Day05.new }
  before do
    allow(day).to receive(:lines).and_return [
      "0,9 -> 5,9",
      "8,0 -> 0,8",
      "9,4 -> 3,4",
      "2,2 -> 2,1",
      "7,0 -> 7,4",
      "6,4 -> 2,0",
      "0,9 -> 2,9",
      "3,4 -> 1,4",
      "0,0 -> 8,8",
      "5,5 -> 8,2",
    ]
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 5 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 12 }
  end
end
