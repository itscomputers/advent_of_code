require 'year2020/day11'

describe Year2020::Day11 do
  let(:day) { Year2020::Day11.new }
  let(:raw_input) do
    <<~INPUT
      L.LL.LL.LL
      LLLLLLL.LL
      L.L.L..L..
      LLLL.LL.LL
      L.LL.LL.LL
      L.LLLLL.LL
      ..L.L.....
      LLLLLLLLLL
      L.LLLLLL.L
      L.LLLLL.LL
    INPUT
  end

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 37 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 26 }
  end

  describe Year2020::Day11::Location do
    describe '#line_of_sight' do
      let(:location_lookup) { day.location_lookup }

      context 'example 1' do
        let(:raw_input) do
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
        end

        let(:location) { location_lookup[[3, 4]] }
        let(:expected_points) do
          [[2, 4], [8, 4], [3, 1], [3, 8], [4, 5], [0, 7], [1, 2], [7, 0]]
        end
        let(:locations) { location.line_of_sight location_lookup }

        it "gives the expected points" do
          expect(locations.map(&:point)).to match_array expected_points
          expect(locations.any?(&:floor?)).to be false
        end
      end

      context 'example 2' do
        let(:raw_input) do
          <<~INPUT
            .............
            .L.L.#.#.#.#.
            .............
          INPUT
        end

        let(:location) { location_lookup[[1, 1]] }
        let(:expected_points) { [[3, 1]] }
        let(:locations) { location.line_of_sight location_lookup }

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
        let(:location) { location_lookup[[3, 3]] }
        let(:locations) { location.line_of_sight location_lookup }

        it "gives the expected points" do
          expect(locations.map(&:point)).to be_empty
        end
      end
    end
  end
end

