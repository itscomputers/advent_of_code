require "year2023/day03"

describe Year2023::Day03 do
  let(:day) { Year2023::Day03.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      467..114..
      ...*......
      ..35..633.
      ......#...
      617*......
      .....+.58.
      ..592.....
      ......755.
      ...$.*....
      .664.598..
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 4361 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 467835 }
  end
end
