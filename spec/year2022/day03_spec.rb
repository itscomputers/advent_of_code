require "year2022/day03"

describe Year2022::Day03 do
  let(:day) { Year2022::Day03.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      vJrwpWtwJgWrhcsFMMfFFhFp
      jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
      PmmdzqPrVvPwwTWBwg
      wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
      ttgJtRGJQctTZtZT
      CrZsJsPPZsGzwwsLwLmpwMDw
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 157 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 70 }
  end
end
