require "year2023/day05"

describe Year2023::Day05 do
  let(:day) { Year2023::Day05.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      seeds: 79 14 55 13

      seed-to-soil map:
      50 98 2
      52 50 48

      soil-to-fertilizer map:
      0 15 37
      37 52 2
      39 0 15

      fertilizer-to-water map:
      49 53 8
      0 11 42
      42 0 7
      57 7 4

      water-to-light map:
      88 18 7
      18 25 70

      light-to-temperature map:
      45 77 23
      81 45 19
      68 64 13

      temperature-to-humidity map:
      0 69 1
      1 0 69

      humidity-to-location map:
      60 56 37
      56 93 4
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 35 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 46 }
  end

  describe "get_ranges" do
    let(:map) { described_class::Map.build(chunk) }
    subject { map.get_ranges(ranges) }

    context "seed-to-soil" do
      let(:chunk) { day.chunks[1] }
      let(:ranges) { [79..92, 55..67] }
      it { is_expected.to match_array [81..94, 57..69] }
    end
  end

  describe "seed-to-soil map" do
    subject { map.get(numbers) }
    let(:map) do
      day.maps.find do |map|
        map.source == "seed" && map.destination == "soil"
      end
    end

    context "when numbers are 0..49" do
      let(:numbers) { (0..49).to_a }
      it { is_expected.to eq numbers }
    end

    context "when numbers are 50..97" do
      let(:numbers) { (50..97).to_a }
      it { is_expected.to eq numbers.map { |n| n + 2 } }
    end

    context "when numbers are 98..99" do
      let(:numbers) { (98..99).to_a }
      it { is_expected.to eq numbers.map { |n| n - 48 } }
    end
  end
end
