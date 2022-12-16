require "year2022/day15"

describe Year2022::Day15 do
  let(:day) { Year2022::Day15.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Sensor at x=2, y=18: closest beacon is at x=-2, y=15
      Sensor at x=9, y=16: closest beacon is at x=10, y=16
      Sensor at x=13, y=2: closest beacon is at x=15, y=3
      Sensor at x=12, y=14: closest beacon is at x=10, y=16
      Sensor at x=10, y=20: closest beacon is at x=10, y=16
      Sensor at x=14, y=17: closest beacon is at x=10, y=16
      Sensor at x=8, y=7: closest beacon is at x=2, y=10
      Sensor at x=2, y=0: closest beacon is at x=2, y=10
      Sensor at x=0, y=11: closest beacon is at x=2, y=10
      Sensor at x=20, y=14: closest beacon is at x=25, y=17
      Sensor at x=17, y=20: closest beacon is at x=21, y=22
      Sensor at x=16, y=7: closest beacon is at x=15, y=3
      Sensor at x=14, y=3: closest beacon is at x=15, y=3
      Sensor at x=20, y=1: closest beacon is at x=15, y=3
    RAW_INPUT

    allow(day).to receive(:y_value).and_return 10
    allow(day).to receive(:distress_signal_range).and_return 20
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 26 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 56000011 }
  end
end
