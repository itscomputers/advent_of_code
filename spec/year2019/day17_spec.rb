require 'year2019/day17'

describe Year2019::Day17 do
  let(:day) { Year2019::Day17.new }

  describe 'part 1' do
    subject { day.solve part: 1 }

    before do
      allow(day.ascii).to receive(:lines).and_return <<~LINES.split("\n")
        ..#..........
        ..#..........
        #######...###
        #.#...#...#.#
        #############
        ..#...#...#..
        ..#####...^..
      LINES
    end

    it { is_expected.to eq 76 }
  end
end

