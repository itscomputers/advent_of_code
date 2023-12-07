require "year2023/day07"

describe Year2023::Day07 do
  let(:day) { Year2023::Day07.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      32T3K 765
      T55J5 684
      KK677 28
      KTJJT 220
      QQQJA 483
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 6440 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 5905 }
  end
end
