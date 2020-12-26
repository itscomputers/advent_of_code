require 'year2020/day02'

describe Year2020::Day02 do
  let(:day) { Year2020::Day02.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      1-3 a: abcde
      1-3 b: cdefg
      2-9 c: ccccccccc
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 2 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 1 }
  end
end

