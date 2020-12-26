require 'year2020/day13'

describe Year2020::Day13 do
  let(:day) { Year2020::Day13.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      939
      7,13,x,x,59,x,31,19
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 295 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 1068781 }
  end
end

