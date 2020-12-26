require 'year2020/day08'

describe Year2020::Day08 do
  let(:day) { Year2020::Day08.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~INPUT
      nop +0
      acc +1
      jmp +4
      acc +3
      jmp -3
      acc -99
      acc +1
      jmp -4
      acc +6
    INPUT
  end

  describe 'part 1' do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 5 }
  end

  describe 'part 2' do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 8 }
  end
end

