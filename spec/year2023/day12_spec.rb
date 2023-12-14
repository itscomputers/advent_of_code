require "year2023/day12"

describe Year2023::Day12 do
  let(:day) { Year2023::Day12.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      ???.### 1,1,3
      .??..??...?##. 1,1,3
      ?#?#?#?#?#?#?#? 1,3,1,6
      ????.#...#... 4,1,1
      ????.######..#####. 1,6,5
      ?###???????? 3,2,1
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 21 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 525152 }
  end
end
