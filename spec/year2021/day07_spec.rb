require "year2021/day07"

describe Year2021::Day07 do
  let(:day) { Year2021::Day07.new }
  before do
    allow(day).to receive(:lines).and_return ["16,1,2,0,4,2,7,1,2,14"]
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 37 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 168 }
  end
end
