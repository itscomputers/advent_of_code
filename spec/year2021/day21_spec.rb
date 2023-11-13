require "year2021/day21"

describe Year2021::Day21 do
  let(:day) { Year2021::Day21.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Player 1 starting position: 4
      Player 2 starting position: 8
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 739785 }
  end

  # test takes 2 seconds
  xdescribe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 444356092776315 }
  end
end
