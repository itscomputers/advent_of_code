require 'advent/day06'

describe Advent::Day06 do
  let(:day) { described_class.build }
  let(:raw_input) do
    [
      "abc",
      "",
      "a",
      "b",
      "c",
      "",
      "ab",
      "ac",
      "",
      "a",
      "a",
      "a",
      "a",
      "",
      "b",
    ].join("\n")
  end
  before { allow(described_class).to receive(:raw_input).and_return raw_input }

  describe '.sanitized_input' do
    subject { described_class.sanitized_input }
    it { is_expected.to eq ["abc", "a\nb\nc", "ab\nac", "a\na\na\na", "b"] }
  end

  describe Advent::Day06::Group do
    let(:group) { described_class.new(string) }

    describe "@answers" do
      subject { group.instance_variable_get :@answers }

      context "when abc" do
        let(:string) { "abc" }
        it { is_expected.to eq [string] }
      end

      context "when a\nb\nc" do
        let(:string) { "a\nb\nc" }
        it { is_expected.to eq ["a", "b", "c"] }
      end
    end

    describe "unique answers" do
      subject { group.unique_answers }

      context "when abc" do
        let(:string) { "abc" }
        it { is_expected.to eq ["a", "b", "c"].to_set }
      end

      context "when ab\nbc" do
        let(:string) { "ab\nbc" }
        it { is_expected.to eq ["a", "b", "c"].to_set }
      end
    end

    describe "common answers" do
      subject { group.common_answers }

      context "when abc" do
        let(:string) { "abc" }
        it { is_expected.to eq ["a", "b", "c"].to_set }
      end

      context "when ab\nbc" do
        let(:string) { "ab\nbc" }
        it { is_expected.to eq ["b"].to_set }
      end
    end
  end
end

