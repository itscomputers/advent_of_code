require 'year2020/day17'

describe Year2020::Day17 do
  let(:day) { Year2020::Day17.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      .#.
      ..#
      ###
    INPUT
  end

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 112 }
  end

# slow spec
# describe 'part 2' do
#   subject { day.solve part: 2 }
#   it { is_expected.to eq 848 }
# end
end

