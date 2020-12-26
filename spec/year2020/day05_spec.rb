require 'year2020/day05'

describe Year2020::Day05 do
  let(:day) { Year2020::Day05.new }

  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      FBFBBFFRLR
      BFFFBBFRRR
      FFFBBBFRRR
      BBFFBBFRLL
    INPUT
  end

  describe '#ids' do
    subject { day.ids }
    it { is_expected.to eq [119, 357, 567, 820] }
  end
end

