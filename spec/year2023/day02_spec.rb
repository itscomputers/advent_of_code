require "year2023/day02"

describe Year2023::Day02 do
  let(:day) { Year2023::Day02.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
      Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
      Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
      Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
      Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 8 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 2286 }
  end
end
