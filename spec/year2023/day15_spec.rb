require "year2023/day15"

describe Year2023::Day15 do
  let(:day) { Year2023::Day15.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 1320 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 145 }
  end
end
