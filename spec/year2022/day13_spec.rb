require "year2022/day13"

describe Year2022::Day13 do
  let(:day) { Year2022::Day13.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      [1,1,3,1,1]
      [1,1,5,1,1]

      [[1],[2,3,4]]
      [[1],4]

      [9]
      [[8,7,6]]

      [[4,4],4,4]
      [[4,4],4,4,4]

      [7,7,7,7]
      [7,7,7]

      []
      [3]

      [[[]]]
      [[]]

      [1,[2,[3,[4,[5,6,7]]]],8,9]
      [1,[2,[3,[4,[5,6,0]]]],8,9]
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 13 }
  end

  describe "comparisons" do
    subject { day.comparisons }
    it { is_expected.to eq [-1, -1, 1, -1, 1, -1, 1, 1] }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 140 }
  end
end
