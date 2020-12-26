require 'year2020/day10'

describe Year2020::Day10 do
  let(:day) { Year2020::Day10.new }
  let(:lines_1) { [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4] }
  let(:lines_2) { [
    28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19,
    38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3,
  ] }

  before { allow(day).to receive(:lines).and_return lines }

  describe 'part 1' do
    subject { day.solve part: 1 }

    context 'example 1' do
      let(:lines) { lines_1 }
      it { is_expected.to eq 35 }
    end

    context 'example 2' do
      let(:lines) { lines_2 }
      it { is_expected.to eq 220 }
    end
  end

  describe 'part 2' do
    subject { day.solve part: 2 }

    context 'example 1' do
      let(:lines) { lines_1 }
      it { is_expected.to eq 8 }
    end

    context 'example 2' do
      let(:lines) { lines_2 }
      it { is_expected.to eq 19208 }
    end
  end
end

