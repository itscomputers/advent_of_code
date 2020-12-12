require 'advent/day12'

describe Advent::Day12 do
  let(:day) { Advent::Day12.build }
  let(:raw_input) do
    <<~INPUT
      F10
      N3
      F7
      R90
      F11
    INPUT
  end

  before { allow(Advent::Day12).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 25 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 286 }
  end
end

