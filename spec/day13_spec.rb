require 'advent/day13'

describe Advent::Day13 do
  let(:day) { Advent::Day13.build }
  let(:raw_input) do
    <<~INPUT
      939
      7,13,x,x,59,x,31,19
    INPUT
  end

  before { allow(Advent::Day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 295 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 1068781 }
  end
end

