require "year2023/day21"

describe Year2023::Day21 do
  let(:day) { Year2023::Day21.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      ...........
      .....###.#.
      .###.##..#.
      ..#.#...#..
      ....#.#....
      .##..S####.
      .##..#...#.
      .......##..
      .##.#.####.
      .##..##.##.
      ...........
    RAW_INPUT
  end

  describe "part 1" do
    before do
      allow_any_instance_of(described_class::BFS).to receive(:step_count).and_return 6
    end
    subject { day.solve(part: 1) }
    it { is_expected.to eq 16 }
  end
end
