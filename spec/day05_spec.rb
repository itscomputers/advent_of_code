require 'advent/day05'

describe Advent::Day05 do
  describe '.sanitized_input' do
    subject { described_class.sanitized_input }

    it { is_expected.to be_a Array }

    it "has strings of length 10" do
      subject.map do |s|
        expect(s).to be_a String
        expect(s.length).to eq 10
      end
    end
  end

  describe '#ordered_seat_ids' do
    let(:input) { %w(BFFFBBFRRR FFFBBBFRRR BBFFBBFRLL) }
    let(:day) { described_class.new(input) }
    subject { day.ordered_seat_ids }

    it { is_expected.to eq [119, 567, 820] }
  end
end

