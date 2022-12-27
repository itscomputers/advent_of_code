require "year2022/day22"

describe Year2022::Day22 do
  let(:day) { Year2022::Day22.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
              ...#
              .#..
              #...
              ....
      ...#.......#
      ........#...
      ..#....#....
      ..........#.
              ...#....
              .....#..
              .#......
              ......#.

      10R5L5R10L4R5L5
    RAW_INPUT
    allow(day).to receive(:cube_face_size).and_return 4
    allow(day).to receive(:cube_face_mapping).and_return(
      {
        [2, 0] => [[-1, 0], 0],
        [0, 1] => [[1, 2], 2],
        [1, 1] => [[-1, -1], 1],
        [2, 1] => [[-1, 0], 0],
        [2, 2] => [[-1, 0], 0],
        [3, 2] => [[-1, -2], 2],
      }
    )
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 6032 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 5031 }
  end

  describe "moving forward" do
    let(:path) do
      day.path(part: 1).tap do |path|
        path.instance_variable_set(:@position, [2, 5])
        path.instance_variable_set(:@direction, direction)
      end
    end

    context "part 1" do
      let(:part) { 1 }

      [
        {direction: [1, 0], line_of_sight: [[2, 5], [3, 5], [4, 5], [5, 5], [6, 5], [7, 5]]},
        {direction: [-1, 0], line_of_sight: [[2, 5], [1, 5], [0, 5], [11, 5], [10, 5], [9, 5]]},
        {direction: [0, 1], line_of_sight: [[2, 5]]},
        {direction: [0, -1], line_of_sight: [[2, 5], [2, 4], [2, 7]]},
      ].each do |test|
        context "when direction is #{test[:direction]}" do
          let(:direction) { test[:direction] }

          describe "line_of_sight" do
            subject { path.line_of_sight }
            it { is_expected.to eq test[:line_of_sight] }
          end

          describe "position after move_forward" do
            subject do
              path.tap do |p|
                p.instance_variable_set(:@movement, 10)
                p.move_forward
              end.instance_variable_get(:@position)
            end
            it { is_expected.to eq test[:line_of_sight].last }
          end
        end
      end
    end

    context "cube_grid" do
      let(:cube_grid) { day.cube_grid }
      subject { cube_grid.display.split("\n").map(&:rstrip).join("\n") }
      it do
        is_expected.to eq <<~RAW.chomp
          ..#....#.#..
          .....#......
          ....#.....#.
          ............
              ...#
              #...
              ....
              ..#.
              ...#
              ....
              .#..
              ....
              ....
              .#..
              ....
              #...
        RAW
      end
    end
  end
end
