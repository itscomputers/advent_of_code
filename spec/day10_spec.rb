require 'advent/day10'

describe Advent::Day10 do
  describe 'part 2' do
    subject { described_class.new(input).solve part: 2 }

    context 'example 1' do
      let(:input) { [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4] }
      it { is_expected.to eq 8 }
    end

    context 'example 2' do
      let(:input) { [
        28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19,
        38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3,
      ] }
      it { is_expected.to eq 19208 }
    end
  end
end

