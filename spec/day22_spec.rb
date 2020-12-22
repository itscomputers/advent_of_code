require 'advent/day22'

describe Advent::Day22 do
  let(:day) { Advent::Day22.build }
  let(:raw_input) do
    <<~INPUT
      Player 1:
      9
      2
      6
      3
      1

      Player 2:
      5
      8
      4
      7
      10
    INPUT
  end

  before { allow(Advent::Day22).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 306 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 291 }
  end
end

