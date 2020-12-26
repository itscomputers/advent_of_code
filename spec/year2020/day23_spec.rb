require 'year2020/day23'

describe Year2020::Day23 do
  let(:day) { Year2020::Day23.new }
  let(:raw_input) {  }

  before { allow(day).to receive(:raw_input).and_return "389125467" }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq "67384529" }
  end

# slow spec
# describe 'part 2' do
#   subject { day.solve part: 2 }
#   it { is_expected.to eq 149245887792 }
# end

  describe Year2020::Day23::CrabCupGame do
    let(:crab_cups) { described_class.new "389125467".chars.map(&:to_i) }

    context "after 10 moves" do
      it "has the right part one string" do
        crab_cups.advance_by(10)
        expect(crab_cups.part_one).to eq "92658374"
      end
    end
  end
end

