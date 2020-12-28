require 'year2019/day10'

describe Year2019::Day10 do
  let(:day) { Year2019::Day10.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      .#..##.###...#######
      ##.############..##.
      .#.######.########.#
      .###.#######.####.#.
      #####.##.#.##.###.##
      ..#####..#.#########
      ####################
      #.####....###.#.#.##
      ##.#################
      #####.##.###..####..
      ..######..##.#######
      ####.##.####...##..#
      .#####..#.######.###
      ##...#.##########...
      #.##########.#######
      .####.#.###.###.#.##
      ....##.##.###..#####
      .#.#.###########.###
      #.#.#.#####.####.###
      ###.##.####.##.#..##
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 210 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 802 }
  end
end

