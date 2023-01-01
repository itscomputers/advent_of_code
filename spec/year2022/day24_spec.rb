require "year2022/day24"

describe Year2022::Day24 do
  let(:day) { Year2022::Day24.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      #.######
      #>>.<^<#
      #.<..<<#
      #>v.><>#
      #<^v^^>#
      ######.#
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 18 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 54 }
  end
end
