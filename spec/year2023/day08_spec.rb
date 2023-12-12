require "year2023/day08"

describe Year2023::Day08 do
  let(:day) { Year2023::Day08.new }
  describe "part 1" do
    context "example 1" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          RL

          AAA = (BBB, CCC)
          BBB = (DDD, EEE)
          CCC = (ZZZ, GGG)
          DDD = (DDD, DDD)
          EEE = (EEE, EEE)
          GGG = (GGG, GGG)
          ZZZ = (ZZZ, ZZZ)
        RAW_INPUT
      end

      subject { day.solve(part: 1) }
      it { is_expected.to eq 2 }
    end

    context "example 2" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          LLR

          AAA = (BBB, BBB)
          BBB = (AAA, ZZZ)
          ZZZ = (ZZZ, ZZZ)
        RAW_INPUT
      end

      subject { day.solve(part: 1) }
      it { is_expected.to eq 6 }
    end
  end

  describe "part 2" do
    before do
      allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
        LR

        11A = (11B, XXX)
        11B = (XXX, 11Z)
        11Z = (11B, XXX)
        22A = (22B, XXX)
        22B = (22C, 22C)
        22C = (22Z, 22Z)
        22Z = (22B, 22B)
        XXX = (XXX, XXX)
      RAW_INPUT
    end
    subject { day.solve(part: 2) }
    it { is_expected.to eq 6 }
  end
end
