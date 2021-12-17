require "year2021/day11"

describe Year2021::Day11 do
  let(:day) { Year2021::Day11.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW
      5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526
    RAW
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 1656 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 195 }
  end

  describe "simple octopus tracker" do
    let(:octopus_tracker) { day.octopus_tracker }

    before do
      allow(day).to receive(:raw_input).and_return <<~RAW
        11111
        19991
        19191
        19991
        11111
      RAW
    end

    describe "step 1" do
      subject { octopus_tracker.step.display }
      let(:expected_display) do
        <<~RAW
          34543
          40004
          50005
          40004
          34543
        RAW
      end
      it { is_expected.to eq expected_display.chomp }
    end

    describe "step 2" do
      subject { octopus_tracker.step.step.display }
      let(:expected_display) do
        <<~RAW
          45654
          51115
          61116
          51115
          45654
        RAW
      end
      it { is_expected.to eq expected_display.chomp }
    end
  end

  describe "octopus tracker" do
    let(:octopus_tracker) { day.octopus_tracker }

    describe "step 1" do
      subject { octopus_tracker.step.display }
      let(:expected_display) do
        <<~RAW
          6594254334
          3856965822
          6375667284
          7252447257
          7468496589
          5278635756
          3287952832
          7993992245
          5957959665
          6394862637
        RAW
      end
      it { is_expected.to eq expected_display.chomp }
    end

    describe "step 2" do
      subject { octopus_tracker.step.step.display }
      let(:expected_display) do
        <<~RAW
          8807476555
          5089087054
          8597889608
          8485769600
          8700908800
          6600088989
          6800005943
          0000007456
          9000000876
          8700006848
        RAW
      end
#     it { is_expected.to eq expected_display.chomp }
    end
  end
end
