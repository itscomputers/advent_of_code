require "year2023/day22"

describe Year2023::Day22 do
  let(:day) { Year2023::Day22.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      1,0,1~1,2,1
      0,0,2~2,0,2
      0,2,3~2,2,3
      0,0,4~0,2,4
      2,0,5~2,2,5
      0,1,6~2,1,6
      1,1,8~1,1,9
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 5 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 7 }
  end
end
