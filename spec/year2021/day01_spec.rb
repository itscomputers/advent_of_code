require "year2021/day01"

describe Year2021::Day01 do
  let(:day) { Year2021::Day01.new }
  before do
    allow(day).to receive(:lines).and_return %w(199 200 208 210 200 207 240 269 260 263)
  end

  describe "part 1" do
    subject { day.solve part: 1 }
    it { is_expected.to eq 7 }
  end

  describe "part 2" do
    subject { day.solve part: 2 }
    it { is_expected.to eq 5 }
  end
end

