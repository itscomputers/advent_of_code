require 'year2020/day06'

describe Year2020::Day06 do
  let(:day) { Year2020::Day06.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      abc

      a
      b
      c

      ab
      ac

      a
      a
      a
      a

      b
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 11 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 6 }
  end
end

