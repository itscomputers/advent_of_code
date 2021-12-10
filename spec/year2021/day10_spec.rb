require "year2021/day10"

describe Year2021::Day10 do
  let(:day) { Year2021::Day10.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW
      [({(<(())[]>[[{[]{<()<>>
      [(()[<>])]({[<{<<[]>>(
      {([(<{}[<>[]}>{[]{[(<()>
      (((({<>}<{<{<>}{[]{[]{}
      [[<[([]))<([[{}[[()]]]
      [{[{({}]{}}([{[{{{}}([]
      {<[[]]>}<{[{[{[]{()[[[]
      [<(<(<(<{}))><([]([]()
      <{([([[(<>()){}]>(<<{{
      <{([{{}}[<[[[<>{}]]]>[]]
    RAW
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 26397 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 288957 }
  end
end
