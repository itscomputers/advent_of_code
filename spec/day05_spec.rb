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

  describe Advent::Day05::Seat do
    let(:seat) { described_class.new(string) }

    describe "row" do
      subject { seat.row }

      context "when BFFFBBFRRR" do
        let(:string) { "BFFFBBFRRR" }
        it { is_expected.to eq 70 }
      end

      context "when FFFBBBFRRR" do
        let(:string) { "FFFBBBFRRR" }
        it { is_expected.to eq 14 }
      end

      context "when BBFFBBFRLL" do
        let(:string) { "BBFFBBFRLL" }
        it { is_expected.to eq 102 }
      end
    end

    describe "col" do
      subject { seat.col }

      context "when BFFFBBFRRR" do
        let(:string) { "BFFFBBFRRR" }
        it { is_expected.to eq  7 }
      end

      context "when FFFBBBFRRR" do
        let(:string) { "FFFBBBFRRR" }
        it { is_expected.to eq 7 }
      end

      context "when BBFFBBFRLL" do
        let(:string) { "BBFFBBFRLL" }
        it { is_expected.to eq 4 }
      end
    end

    describe "seat_id" do
      subject { seat.seat_id }

      context "when BFFFBBFRRR" do
        let(:string) { "BFFFBBFRRR" }
        it { is_expected.to eq 567 }
      end

      context "when FFFBBBFRRR" do
        let(:string) { "FFFBBBFRRR" }
        it { is_expected.to eq 119 }
      end

      context "when BBFFBBFRLL" do
        let(:string) { "BBFFBBFRLL" }
        it { is_expected.to eq 820 }
      end
    end
  end
end

