require 'advent/day25'

describe Advent::Day25 do
  let(:day) { Advent::Day25.build }
  let(:raw_input) do
    <<~INPUT
      5764801
      17807724
    INPUT
  end

  before { allow(Advent::Day25).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 14897079 }
  end
end

