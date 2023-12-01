require "year2023/day01"

describe Year2023::Day01 do
  let(:day) { Year2023::Day01.new }
  describe "part 1" do
    before do
      allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
        1abc2
        pqr3stu8vwx
        a1b2c3d4e5f
        treb7uchet
      RAW_INPUT
    end

    subject { day.solve(part: 1) }
    it { is_expected.to eq 142 }
  end

  describe "part 2" do
    before do
      allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
        two1nine
        eightwothree
        abcone2threexyz
        xtwone3four
        4nineeightseven2
        zoneight234
        7pqrstsixteen
      RAW_INPUT
    end
    subject { day.solve(part: 2) }
    it { is_expected.to eq 281 }
  end
end
