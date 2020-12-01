require 'advent/day01'

describe Advent::Day01 do
  describe ".sanitized_input" do
    subject { described_class.sanitized_input }

    it { is_expected.to be_a Array }

    it "has integer values" do
      expect(subject.map(&:class).uniq).to eq [Integer]
    end
  end

  describe "example 1" do
    let(:input) { [1721, 979, 366, 299, 675, 1456] }
    let(:sum) { 2020 }
    let(:day) { described_class.new(input, sum: sum) }

    describe "#pair" do
      subject { day.pair }
      it { is_expected.to match_array [1721, 299] }
    end

    describe "#part 1" do
      subject { day.solve(part: 1) }
      it { is_expected.to eq 514579 }
    end

    describe "#trio" do
      subject { day.trio }
      it { is_expected.to match_array [979, 366, 675] }
    end

    describe "#part 2" do
      subject { day.solve(part: 2) }
      it { is_expected.to eq 241861950 }
    end
  end
end

