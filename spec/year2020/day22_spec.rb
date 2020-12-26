require 'year2020/day22'

describe Year2020::Day22 do
  let(:day) { Year2020::Day22.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
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

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 306 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 291 }
  end
end

