require "year2022/day09"

describe Year2022::Day09 do
  let(:day) { Year2022::Day09.new }
  let(:raw_input) {
    <<~RAW_INPUT
      R 4
      U 4
      L 3
      D 1
      R 4
      D 1
      L 5
      R 2
    RAW_INPUT
  }

  before do
    allow(day).to receive(:raw_input).and_return raw_input
  end

  describe "part 1 " do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 13 }
  end

  describe "part 2 " do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 1 }

    describe "example 2" do
      let(:raw_input) {
        <<~RAW_INPUT
          R 5
          U 8
          L 8
          D 3
          R 17
          D 10
          L 25
          U 20
        RAW_INPUT
      }
      it { is_expected.to eq 36 }
    end
  end
end
