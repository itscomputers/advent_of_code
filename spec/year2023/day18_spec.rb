require "year2023/day18"

describe Year2023::Day18 do
  let(:day) { Year2023::Day18.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      R 6 (#70c710)
      D 5 (#0dc571)
      L 2 (#5713f0)
      D 2 (#d2c081)
      R 2 (#59c680)
      D 2 (#411b91)
      L 5 (#8ceee2)
      U 2 (#caa173)
      L 1 (#1b58a2)
      U 2 (#caa171)
      R 2 (#7807d2)
      U 3 (#a77fa3)
      L 2 (#015232)
      U 2 (#7a21e3)
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 62 }
  end

  xdescribe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 952408144115 }
  end
end
