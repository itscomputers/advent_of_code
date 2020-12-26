require 'year2020/day12'

describe Year2020::Day12 do
  let(:day) { Year2020::Day12.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      F10
      N3
      F7
      R90
      F11
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 25 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 286 }
  end
end

