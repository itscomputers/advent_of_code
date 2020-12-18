require 'advent/day18'

describe Advent::Day18 do
  describe Advent::Day18::Expression do
    let(:expression) { described_class.new string.gsub(/ +/, "").chars }

    describe "#chars" do
      subject { expression.chars }

      before { allow_any_instance_of(described_class).to receive(:evaluate).and_return('hi') }

      context "when string is 1 + 2 * 3 + 4 * 5 + 6" do
        let(:string) { "1 + 2 * 3 + 4 * 5 + 6" }
        it { is_expected.to eq string.split(" ") }
      end

      context "when string is 2 * 3 + (4 * 5)" do
        let(:string) { "2 * 3 + (4 * 5)" }
        it { is_expected.to eq "2 * 3 + hi".split(" ") }
      end

      context "when string is 1 + (2 * 3) + (4 * (5 + 6))" do
        let(:string) { "1 + (2 * 3) + (4 * (5 + 6))" }
        it { is_expected.to eq "1 + hi + hi".split(" ") }
      end

      context "when string is ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" do
        let(:string) { "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" }
        it { is_expected.to eq "hi + 2 + 4 * 2".split(" ") }
      end
    end

    describe "#evaluate" do
      subject { expression.evaluate }

      context "when string is 1 + 2 * 3 + 4 * 5 + 6" do
        let(:string) { "1 + 2 * 3 + 4 * 5 + 6" }
        it { is_expected.to eq 71 }
      end

      context "when string is 1 + (2 * 3) + (4 * (5 + 6))" do
        let(:string) { "1 + (2 * 3) + (4 * (5 + 6))" }
        it { is_expected.to eq 51 }
      end

      context "when string is 2 * 3 + (4 * 5)" do
        let(:string) { "2 * 3 + (4 * 5)" }
        it { is_expected.to eq 26 }
      end

      context "when string is 5 + (8 * 3 + 9 + 3 * 4 * 3)" do
        let(:string) { "5 + (8 * 3 + 9 + 3 * 4 * 3)" }
        it { is_expected.to eq 437 }
      end

      context "when string is 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" do
        let(:string) { "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" }
        it { is_expected.to eq 12240 }
      end

      context "when string is ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" do
        let(:string) { "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" }
        it { is_expected.to eq 13632 }
      end
    end
  end

  describe "modified order of operations" do
    subject { string.evaluate_with_modified_order_of_operations }

    context "when string is 1 + 2 * 3 + 4 * 5 + 6" do
      let(:string) { "1 + 2 * 3 + 4 * 5 + 6" }
      it { is_expected.to eq 231 }
    end

    context "when string is 1 + (2 * 3) + (4 * (5 + 6))" do
      let(:string) { "1 + (2 * 3) + (4 * (5 + 6))" }
      it { is_expected.to eq 51 }
    end

    context "when string is 2 * 3 + (4 * 5)" do
      let(:string) { "2 * 3 + (4 * 5)" }
      it { is_expected.to eq 46 }
    end

    context "when string is 5 + (8 * 3 + 9 + 3 * 4 * 3)" do
      let(:string) { "5 + (8 * 3 + 9 + 3 * 4 * 3)" }
      it { is_expected.to eq 1445 }
    end

    context "when string is 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" do
      let(:string) { "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" }
      it { is_expected.to eq 669060 }
    end

    context "when string is ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" do
      let(:string) { "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" }
      it { is_expected.to eq 23340 }
    end
  end
end

