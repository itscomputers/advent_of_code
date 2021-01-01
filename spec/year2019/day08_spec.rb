require 'year2019/day08'

describe Year2019::Day08 do
  let(:day) { Year2019::Day08.new }
  before do
    allow(day).to receive(:raw_input).and_return "0222112222120000"
    allow(day).to receive(:width).and_return 2
    allow(day).to receive(:height).and_return 2
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq "\n #\n# " }
  end
end

