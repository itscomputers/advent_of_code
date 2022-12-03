require "year2022/day02"

describe Year2022::Day02 do
  let(:day) { Year2022::Day02.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      A Y
      B X
      C Z
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 15 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 12 }
  end

  describe Year2022::Day02::Round do
    describe "number" do
      {
        "X" => 1,
        "Y" => 2,
        "Z" => 3,
      }.each do |(shape, expected_number)|
        it "has the expected number for #{shape}" do
          expect(described_class.new("A", shape).number).to eq expected_number
        end
      end
    end

    describe "outcome" do
      {
        ["A", "X"] => 3,
        ["B", "Y"] => 3,
        ["C", "Z"] => 3,
        ["A", "Z"] => 0,
        ["B", "X"] => 0,
        ["C", "Y"] => 0,
        ["A", "Y"] => 6,
        ["B", "Z"] => 6,
        ["C", "X"] => 6,
      }.each do |(round, expected_outcome)|
        it "has the expected outcome for #{round}" do
          expect(described_class.new(*round).outcome).to eq expected_outcome
        end
      end
    end
  end

  describe Year2022::Day02::RoundV2 do
    describe "outcome" do
      {
        "X" => 0,
        "Y" => 3,
        "Z" => 6,
      }.each do |(shape, expected_outcome)|
        it "has the expected outcome for #{shape}" do
          expect(described_class.new("A", shape).outcome).to eq expected_outcome
        end
      end
    end

    describe "number" do
      {
        ["A", "X"] => 3,
        ["B", "X"] => 1,
        ["C", "X"] => 2,
        ["A", "Y"] => 1,
        ["B", "Y"] => 2,
        ["C", "Y"] => 3,
        ["A", "Z"] => 2,
        ["B", "Z"] => 3,
        ["C", "Z"] => 1,
      }.each do |(round, expected_number)|
        it "has the expected number for #{round}" do
          expect(described_class.new(*round).number).to eq expected_number
        end
      end
    end
  end
end
