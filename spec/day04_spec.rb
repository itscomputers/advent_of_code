require 'advent/day04'

describe Advent::Day04 do
  let(:day) { described_class.new(input) }

  let(:input) { described_class.sanitized_input }
  let(:raw_input) do
    [
      "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd",
      "byr:1937 iyr:2017 cid:147 hgt:183cm",
      "",
      "iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884",
      "hcl:#cfa07d byr:1929",
      "",
      "hcl:#ae17e1 iyr:2013",
      "eyr:2024",
      "ecl:brn pid:760753108 byr:1931",
      "hgt:179cm",
      "",
      "hcl:#cfa07d eyr:2025 pid:166559648",
      "iyr:2011 ecl:brn hgt:59in",
    ].join("\n")
  end

  before { allow(described_class).to receive(:raw_input).and_return raw_input }

  describe ".sanitized_input" do
    it "matches the input" do
      expect(input).to eq([
        {
          "ecl" => "gry",
          "pid" => "860033327",
          "eyr" => "2020",
          "hcl" => "#fffffd",
          "byr" => "1937",
          "iyr" => "2017",
          "cid" => "147",
          "hgt" => "183cm",
        },
        {
          "ecl" => "amb",
          "pid" => "028048884",
          "eyr" => "2023",
          "hcl" => "#cfa07d",
          "byr" => "1929",
          "iyr" => "2013",
          "cid" => "350",
        },
        {
          "ecl" => "brn",
          "pid" => "760753108",
          "eyr" => "2024",
          "hcl" => "#ae17e1",
          "byr" => "1931",
          "iyr" => "2013",
          "hgt" => "179cm",
        },
        {
          "ecl" => "brn",
          "pid" => "166559648",
          "eyr" => "2025",
          "hcl" => "#cfa07d",
          "iyr" => "2011",
          "hgt" => "59in",
        },
      ])
    end
  end

  describe "#part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 2 }
  end

  describe Advent::Day04::ComplexPolicy do
    let(:policy) { described_class.new }

    describe "#byr" do
      subject { policy.byr value }

      context "when 2002" do
        let(:value) { "2002" }
        it { is_expected.to be true }
      end

      context "when 1919" do
        let(:value) { "1919" }
        it { is_expected.to be false }
      end

      context "when 2003" do
        let(:value) { "2003" }
        it { is_expected.to be false }
      end
    end

    describe "#hgt" do
      subject { policy.hgt value }

      context "when 60in" do
        let(:value) { "60in" }
        it { is_expected.to be true }
      end

      context "when 190cm" do
        let(:value) { "190cm" }
        it { is_expected.to be true }
      end

      context "when 190in" do
        let(:value) { "190in" }
        it { is_expected.to be false }
      end

      context "when 190" do
        let(:value) { "190" }
        it { is_expected.to be false }
      end
    end

    describe "#hcl" do
      subject { policy.hcl value }

      context "when #123abc" do
        let(:value) { "#123abc" }
        it { is_expected.to be true }
      end

      context "when #123abz" do
        let(:value) { "#123abz" }
        it { is_expected.to be false }
      end

      context "when 123abc" do
        let(:value) { "123abc" }
        it { is_expected.to be false }
      end
    end

    describe "#ecl" do
      subject { policy.ecl value }

      context "when brn" do
        let(:value) { "brn" }
        it { is_expected.to be true }
      end

      context "when wtf" do
        let(:value) { "wtf" }
        it { is_expected.to be false }
      end
    end

    describe "#pid" do
      subject { policy.pid value }

      context "when 000000001" do
        let(:value) { "000000001" }
        it { is_expected.to be true }
      end

      context "when 0123456789" do
        let(:value) { "0123456789" }
        it { is_expected.to be false }
      end
    end
  end
end

