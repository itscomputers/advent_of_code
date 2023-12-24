require "year2023/day17"

describe Year2023::Day17 do
  let(:day) { Year2023::Day17.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      2413432311323
      3215453535623
      3255245654254
      3446585845452
      4546657867536
      1438598798454
      4457876987766
      3637877979653
      4654967986887
      4564679986453
      1224686865563
      2546548887735
      4322674655533
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 102 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 94 }
  end
end
