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
    allow(day).to receive(:size).and_return 4
    allow(day).to receive(:edge_mapping).and_return(
      {
        [[2, 0], [1, 0]] => {
          1 => [[2, 0], [1, 0]],
          2 => [[3, 2], [-1, 0]],
        },
        [[2, 0], [-1, 0]] => {
          1 => [[2, 0], [-1, 0]],
          2 => [[1, 1], [0, 1]],
        },
        [[2, 0], [0, -1]] => {
          1 => [[2, 2], [0, -1]],
          2 => [[0, 1], [0, 1]],
        },
        [[0, 1], [-1, 0]] => {
          1 => [[2, 1], [-1, 0]],
          2 => [[3, 2], [0, -1]],
        },
        [[0, 1], [0, -1]] => {
          1 => [[0, 1], [0, -1]],
          2 => [[2, 0], [0, 1]],
        },
        [[0, 1], [0, 1]] => {
          1 => [[0, 1], [0, 1]],
          2 => [[2, 2], [0, -1]],
        },
        [[1, 1], [0, -1]] => {
          1 => [[1, 1], [0, -1]],
          2 => [[2, 0], [1, 0]],
        },
        [[1, 1], [0, 1]] => {
          1 => [[1, 1], [0, 1]],
          2 => [[2, 2], [1, 0]],
        },
        [[2, 1], [1, 0]] => {
          1 => [[0, 1], [1, 0]],
          2 => [[3, 2], [0, 1]],
        },
        [[2, 2], [-1, 0]] => {
          1 => [[3, 2], [-1, 0]],
          2 => [[1, 1], [0, -1]],
        },
        [[2, 2], [0, 1]] => {
          1 => [[2, 0], [0, 1]],
          2 => [[0, 1], [0, -1]],
        },
        [[3, 2], [0, 1]] => {
          1 => [[3, 2], [0, 1]],
          2 => [[0, 1], [1, 0]],
        },
        [[3, 2], [1, 0]] => {
          1 => [[2, 2], [1, 0]],
          2 => [[2, 0], [-1, 0]],
        },
        [[3, 2], [0, -1]] => {
          1 => [[3, 2], [0, -1]],
          2 => [[2, 1], [-1, 0]],
        },
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

  describe Year2022::Day22::Path do
    let(:path) { day.path(part: part) }

    describe "part 1" do
      let(:part) { 1 }

      [
        *(0..3).zip((8..11).to_a.reverse).map do |(y, cy)|
          [
            [[11, y], [1, 0]],
            [[8, y], [1, 0]],
          ]
        end,
        *(4..7).map do |y|
          [
            [[11, y], [1, 0]],
            [[0, y], [1, 0]],
          ]
        end,
        *(8..11).map do |y|
          [
            [[15, y], [1, 0]],
            [[8, y], [1, 0]],
          ]
        end,
        *(0..7).map do |x|
          [
            [[x, 7], [0, 1]],
            [[x, 4], [0, 1]],
          ]
        end,
        *(8..11).map do |x|
          [
            [[x, 11], [0, 1]],
            [[x, 0], [0, 1]],
          ]
        end,
        *(12..15).map do |x|
          [
            [[x, 11], [0, 1]],
            [[x, 8], [0, 1]],
          ]
        end,
      ].each do |test|
        describe "#{test[0]}" do
          let(:point) { described_class::DirectedPoint.new(*test[0]) }
          let(:other) { described_class::DirectedPoint.new(*test[1]) }

          let(:reverse_point) do
            described_class::DirectedPoint.new(
              test[0][0],
              Vector.scale(test[0][1], -1),
            )
          end
          let(:reverse_other) do
            described_class::DirectedPoint.new(
              test[1][0],
              Vector.scale(test[1][1], -1),
            )
          end

          it "has #{test[1]} as next" do
            expect(path.next_directed_point(point)).to eq other
          end

          it "is next after #{test[1]} (reversed)" do
            expect(path.next_directed_point(reverse_other)).to eq reverse_point
          end
        end
      end
    end

    describe "part 2" do
      let(:part) { 2 }

      [
        *(0..3).zip((8..11).to_a.reverse).map do |(y, cy)|
          [
            [[11, y], [1, 0]],
            [[15, cy], [-1, 0]],
          ]
        end,
        *(0..3).zip((8..11).to_a.reverse).flat_map do |(x, cx)|
          [
            [
              [[x, 4], [0, -1]],
              [[cx, 0], [0, 1]],
            ],
            [
              [[x, 7], [0, 1]],
              [[cx, 11], [0, -1]],
            ],
          ]
        end,
        *(0..3).zip((4..7).to_a).map do |(y, cx)|
          [
            [[8, y], [-1, 0]],
            [[cx, 4], [0, 1]],
          ]
        end,
        *(4..7).zip((12..15).to_a.reverse).flat_map do |(y, cx)|
          [
            [
              [[0, y], [-1, 0]],
              [[cx, 11], [0, -1]],
            ],
            [
              [[11, y], [1, 0]],
              [[cx, 8], [0, 1]],
            ],
          ]
        end,
        *(4..7).zip((8..11).to_a.reverse).map do |(x, cy)|
          [
            [[x, 7], [0, 1]],
            [[8, cy], [1, 0]],
          ]
        end,
      ].each do |test|
        describe "#{test[0]}" do
          let(:point) { described_class::DirectedPoint.new(*test[0]) }
          let(:other) { described_class::DirectedPoint.new(*test[1]) }

          let(:reverse_point) do
            described_class::DirectedPoint.new(
              test[0][0],
              Vector.scale(test[0][1], -1),
            )
          end
          let(:reverse_other) do
            described_class::DirectedPoint.new(
              test[1][0],
              Vector.scale(test[1][1], -1),
            )
          end

          it "has #{test[1]} as next" do
            expect(path.next_directed_point(point)).to eq other
          end

          it "is next after #{test[1]} (reversed)" do
            expect(path.next_directed_point(reverse_other)).to eq reverse_point
          end
        end
      end
    end
  end
end
