require 'advent/day17'

describe Advent::Day17 do
  let(:day) { Advent::Day17.build }
  let(:raw_input) do
    <<~INPUT
      .#.
      ..#
      ###
    INPUT
  end

  before { allow(Advent::Day17).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 112 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 848 }
  end
end

