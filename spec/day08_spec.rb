require 'advent/day08'

describe Advent::Day08 do
  let(:raw_input) do
    [
      "nop +0",
      "acc +1",
      "jmp +4",
      "acc +3",
      "jmp -3",
      "acc -99",
      "acc +1",
      "jmp -4",
      "acc +6",
    ].join("\n")
  end

  before { allow(described_class).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { described_class.build.solve(part: 1) }
    it { is_expected.to eq 5 }
  end

  describe 'part 2' do
    subject { described_class.build.solve(part: 2) }
    it { is_expected.to eq 8 }
  end
end

