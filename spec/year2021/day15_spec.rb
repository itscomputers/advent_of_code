require "year2021/day15"

describe Year2021::Day15 do
  let(:raw_input) do
    <<~RAW
      1163751742
      1381373672
      2136511328
      3694931569
      7463417111
      1319128137
      1359912421
      3125421639
      1293138521
      2311944581
    RAW
  end
  let(:day) { Year2021::Day15.new(raw_input) }

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 40 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 315 }
  end

  describe "enlarged grid" do
    let(:raw_input) { "8" }
    subject { day.graph(2).instance_variable_get(:@grid) }
    it do
      expect(Grid.display(subject, type: :hash)).to eq <<~DISPLAY.chomp
        89123
        91234
        12345
        23456
        34567
      DISPLAY
    end
  end
end
