require "year2021/day02"

describe Year2021::Day02 do
  let(:day) { Year2021::Day02.new }
  before do
    allow(day).to receive(:lines).and_return [
      "forward 5",
      "down 5",
      "forward 8",
      "up 3",
      "down 8",
      "forward 2",
    ]
  end

  describe "part 1" do
    subject { day.solve part: 1 }
    it { is_expected.to eq 150 }
  end

  describe "part 2" do
    subject { day.solve part: 2 }
    it { is_expected.to eq 900 }
  end
end
