require 'advent/day02'

describe Advent::Day02 do
  describe '.sanitize_line' do
    let(:expected_hash) { { :lower => lower, :upper => upper, :char => char, :password => password } }
    subject { described_class.sanitize_line(line) }

    context "when 1-3 a: abcde" do
      let(:line) { "1-3 a: abcde" }
      let(:lower) { "1" }
      let(:upper) { "3" }
      let(:char) { "a" }
      let(:password) { "abcde" }

      it { is_expected.to eq expected_hash }
    end

    context "when 1-3 b: cdefg" do
      let(:line) { "1-3 b: cdefg" }
      let(:lower) { "1" }
      let(:upper) { "3" }
      let(:char) { "b" }
      let(:password) { "cdefg" }

      it { is_expected.to eq expected_hash }
    end

    context "when 2-9 c: ccccccccc" do
      let(:line) { "2-9 c: ccccccccc" }
      let(:lower) { "2" }
      let(:upper) { "9" }
      let(:char) { "c" }
      let(:password) { "ccccccccc" }

      it { is_expected.to eq expected_hash }
    end
  end

  describe Advent::Day02::LegacyPasswordPolicy do
    let(:hash) { Advent::Day02.sanitize_line(line) }
    subject { described_class.new(hash) }

    context "when 1-3 a: abcde" do
      let(:line) { "1-3 a: abcde" }
      it { is_expected.to be_valid }
    end

    context "when 1-3 b: cdefg" do
      let(:line) { "1-3 b: cdefg" }
      it { is_expected.to_not be_valid }
    end

    context "when 2-9 c: ccccccccc" do
      let(:line) { "2-9 c: ccccccccc" }
      it { is_expected.to be_valid }
    end
  end

  describe Advent::Day02::PasswordPolicy do
    let(:hash) { Advent::Day02.sanitize_line(line) }
    subject { described_class.new(hash) }

    context "when 1-3 a: abcde" do
      let(:line) { "1-3 a: abcde" }
      it { is_expected.to be_valid }
    end

    context "when 1-3 b: cdefg" do
      let(:line) { "1-3 b: cdefg" }
      it { is_expected.to_not be_valid }
    end

    context "when 2-9 c: ccccccccc" do
      let(:line) { "2-9 c: ccccccccc" }
      it { is_expected.to_not be_valid }
    end
  end
end
