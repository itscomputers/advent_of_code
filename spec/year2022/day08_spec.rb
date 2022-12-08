require "year2022/day08"

describe Year2022::Day08 do
 let(:day) { Year2022::Day08.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      30373
      25512
      65332
      33549
      35390
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 21 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 8 }
  end

  describe "scenery" do
    let(:scenery) { described_class::Scenery.new(day.grid, point) }
    subject { scenery.score }

    context "when point is [2, 1]" do
      let(:point) { [2, 1] }
      it { expect(scenery.sight_lines.map(&:visible_count)).to match_array [1, 1, 2, 2] }
      it { is_expected.to eq 4 }
    end

    context "when point is [2, 3]" do
      let(:point) { [2, 3] }
      it { expect(scenery.sight_lines.map(&:visible_count)).to match_array [1, 2, 2, 2] }
      it { is_expected.to eq 8 }
    end
  end
end
