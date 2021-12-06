require "year2021/day06"

describe Year2021::Day06 do
  let(:day) { Year2021::Day06.new }
  before do
    allow(day).to receive(:lines).and_return ["3,4,3,1,2"]
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 5934 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 26984457539 }
  end
end
