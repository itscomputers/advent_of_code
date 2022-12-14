require "year2022/day14"

describe Year2022::Day14 do
  let(:day) { Year2022::Day14.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      498,4 -> 498,6 -> 496,6
      503,4 -> 502,4 -> 502,9 -> 494,9
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 24 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 93 }
  end

  describe "paths" do
    subject { day.paths.map(&:points) }
    let(:expected_points) { [
      [[496, 6], [497, 6], [498, 6], [498, 5], [498, 4]],
      [
        [494, 9], [495, 9], [496, 9], [497, 9],
        [498, 9], [499, 9], [500, 9], [501, 9],
        [502, 9], [502, 8], [502, 7], [502, 6],
        [502, 5], [502, 4], [503, 4],
      ],
    ] }

    it "has the expected path points" do
      subject.zip(expected_points).each do |points, expected|
        expect(points).to match_array expected
      end
    end
  end

  describe "cave" do
    let(:cave) { day.cave }
    describe "rock lookup" do
      subject { cave.points_lookup }
      it do
        is_expected.to eq({
          494 => [9],
          495 => [9],
          496 => [6, 9],
          497 => [6, 9],
          498 => [4, 5, 6, 9],
          499 => [9],
          500 => [9],
          501 => [9],
          502 => [4, 5, 6, 7, 8, 9],
          503 => [4],
        })
      end
    end

    describe "point?" do
      let(:expected_points) { day.paths.flat_map(&:points).uniq }
      (0..10).each do |x|
        (494..503).each do |y|
          it "is correct for (#{x}, #{y})" do
            expect(cave.point?(x, y)).to be expected_points.include?([x, y])
          end
        end
      end
    end

    describe "landing" do
      it "has the correct landing points" do
        [
          [500, 8],
          [499, 8],
          [501, 8],
          [500, 7],
          [498, 8],
          [499, 7],
          [501, 7],
        ].each do |expected_landing|
          cave.landing(500, 0).tap do |landing|
            expect(landing).to eq expected_landing
            cave.add_point(landing)
          end
        end
      end
    end
  end
end

