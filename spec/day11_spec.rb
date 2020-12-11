require 'advent/day11'

describe Advent::Day11 do
  let(:raw_input) do
    [
      "L.LL.LL.LL",
      "LLLLLLL.LL",
      "L.L.L..L..",
      "LLLL.LL.LL",
      "L.LL.LL.LL",
      "L.LLLLL.LL",
      "..L.L.....",
      "LLLLLLLLLL",
      "L.LLLLLL.L",
      "L.LLLLL.LL",
    ].join("\n")
  end

  before { allow(Advent::Day11).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { described_class.build.solve part: 1 }
    it { is_expected.to eq 37 }
  end

  describe 'part 2' do
    subject { described_class.build.solve part: 2 }
    it { is_expected.to eq 26 }
  end

  describe Advent::Day11::Location do
    describe 'line_of_sight' do
      let(:day) { Advent::Day11.build }
      let(:location_hash) { day.instance_variable_get(:@location_hash) }

      context 'example 1' do
        let(:raw_input) {
          <<~INPUT
            .......#.
            ...#.....
            .#.......
            .........
            ..#L....#
            ....#....
            .........
            #........
            ...#.....
          INPUT
        }
        let(:location) { location_hash[Point.new(3, 4)] }
        let(:expected_points) do
          [[2, 4], [8, 4], [3, 1], [3, 8], [4, 5], [0, 7], [1, 2], [7, 0]].map { |a| Point.new(*a) }
        end
        let(:locations) { location.line_of_sight location_hash }

        it "gives the expected points" do
          expect(locations.map(&:point)).to match_array expected_points
          expect(locations.any?(&:floor?)).to be false
        end
      end

      context 'example 2' do
        let(:raw_input) {
          <<~INPUT
            .............
            .L.L.#.#.#.#.
            .............
          INPUT
        }
        let(:location) { location_hash[Point.new(1, 1)] }
        let(:expected_points) { [Point.new(3, 1)] }
        let(:locations) { location.line_of_sight location_hash }

        it "gives the expected points" do
          expect(locations.map(&:point)).to match_array expected_points
          expect(locations.any?(&:floor?)).to be false
        end
      end

      context 'example 3' do
        let(:raw_input) {
          <<~INPUT
            .##.##.
            #.#.#.#
            ##...##
            ...L...
            ##...##
            #.#.#.#
            .##.##.
          INPUT
        }
        let(:location) { location_hash[Point.new(3, 3)] }
        let(:expected_points) { [] }
        let(:locations) { location.line_of_sight location_hash }

        it "gives the expected points" do
          expect(locations.map(&:point)).to match_array expected_points
          expect(locations.any?(&:floor?)).to be false
        end
      end
    end
  end
end

