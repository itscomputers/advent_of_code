require 'year2020/day01'

describe Year2020::Day01 do
  let(:day) { Year2020::Day01.new }
  before do
    allow(day).to receive(:lines).and_return %w(1721 979 366 299 675 1456)
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 514579 }
  end

  describe "#part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 241861950 }
  end
end

