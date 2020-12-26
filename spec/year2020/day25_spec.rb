require 'year2020/day25'

describe Year2020::Day25 do
  let(:day) { Year2020::Day25.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      5764801
      17807724
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 14897079 }
  end
end

