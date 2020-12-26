require 'year2020/day03'

describe Year2020::Day03 do
  let(:day) { Year2020::Day03.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      ..##.......
      #...#...#..
      .#....#..#.
      ..#.#...#.#
      .#...##..#.
      ..#.##.....
      .#.#.#....#
      .#........#
      #.##...#...
      #...##....#
      .#..#...#.#
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 7 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 336 }
  end
end

