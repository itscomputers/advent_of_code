require "year2022/day25"

describe Year2022::Day25 do
  let(:day) { Year2022::Day25.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      1=-0-2
      12111
      2=0=
      21
      2=01
      111
      20012
      112
      1=-1=
      1-12
      12
      1=
      122
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq "2=-1=0" }
  end

  describe Year2022::Day25::Snafu do
    [
      [1, "1"],
      [2, "2"],
      [3, "1="],
      [4, "1-"],
      [5, "10"],
      [6, "11"],
      [7, "12"],
      [8, "2="],
      [9, "2-"],
      [10, "20"],
      [15, "1=0"],
      [20, "1-0"],
      [2022, "1=11-2"],
      [12345, "1-0---0"],
      [314159265, "1121-1110-1=0"],
    ].each do |test|
      describe "#{test[1]}.to_i" do
        subject { described_class.new(test[1]).to_i }
        it { is_expected.to eq test[0] }
      end

      describe "#{test[0]}.to_snafu" do
        subject { described_class.from_i(test[0]) }
        it { is_expected.to eq test[1] }
      end
    end
  end
end
