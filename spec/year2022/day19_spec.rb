require "year2022/day19"

describe Year2022::Day19 do
  let(:day) { Year2022::Day19.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Blueprint 1: Each ore robot costs 4 ore. Each clay robot costs 2 ore. Each obsidian robot costs 3 ore and 14 clay. Each geode robot costs 2 ore and 7 obsidian.
      Blueprint 2: Each ore robot costs 2 ore. Each clay robot costs 3 ore. Each obsidian robot costs 3 ore and 8 clay. Each geode robot costs 3 ore and 12 obsidian.
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 33 }
  end

# slow test
# describe "part 2" do
#   subject { day.solve(part: 2) }
#   it { is_expected.to eq 56 * 62 }
# end

  describe "blueprints" do
    let(:blueprints) { day.blueprints }

    describe "ids" do
      subject { blueprints.map(&:id) }
      it { is_expected.to eq [1, 2] }
    end

    describe "ore costs" do
      subject { blueprints.map(&:ore).map(&:to_h) }
      it { is_expected.to eq [
        {ore: 4, clay: 0, obsidian: 0},
        {ore: 2, clay: 0, obsidian: 0},
      ] }
    end

    describe "clay costs" do
      subject { blueprints.map(&:clay).map(&:to_h) }
      it { is_expected.to eq [
        {ore: 2, clay: 0, obsidian: 0},
        {ore: 3, clay: 0, obsidian: 0},
      ] }
    end

    describe "obsidian costs" do
      subject { blueprints.map(&:obsidian).map(&:to_h) }
      it { is_expected.to eq [
        {ore: 3, clay: 14, obsidian: 0},
        {ore: 3, clay: 8, obsidian: 0},
      ] }
    end

    describe "geode costs" do
      subject { blueprints.map(&:geode).map(&:to_h) }
      it { is_expected.to eq [
        {ore: 2, clay: 0, obsidian: 7},
        {ore: 3, clay: 0, obsidian: 12},
      ] }
    end
  end



end
