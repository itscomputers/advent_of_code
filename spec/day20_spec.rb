require 'advent/day20'

describe Advent::Day20 do
  let(:day) { Advent::Day20.build }
  let(:raw_input) do
    <<~INPUT
      Tile 2311:
      ..##.#..#.
      ##..#.....
      #...##..#.
      ####.#...#
      ##.##.###.
      ##...#.###
      .#.#.#..##
      ..#....#..
      ###...#.#.
      ..###..###

      Tile 1951:
      #.##...##.
      #.####...#
      .....#..##
      #...######
      .##.#....#
      .###.#####
      ###.##.##.
      .###....#.
      ..#.#..#.#
      #...##.#..

      Tile 1171:
      ####...##.
      #..##.#..#
      ##.#..#.#.
      .###.####.
      ..###.####
      .##....##.
      .#...####.
      #.##.####.
      ####..#...
      .....##...

      Tile 1427:
      ###.##.#..
      .#..#.##..
      .#.##.#..#
      #.#.#.##.#
      ....#...##
      ...##..##.
      ...#.#####
      .#.####.#.
      ..#..###.#
      ..##.#..#.

      Tile 1489:
      ##.#.#....
      ..##...#..
      .##..##...
      ..#...#...
      #####...#.
      #..#.#.#.#
      ...#.#.#..
      ##.#...##.
      ..##.##.##
      ###.##.#..

      Tile 2473:
      #....####.
      #..#.##...
      #.##..#...
      ######.#.#
      .#...#.#.#
      .#########
      .###.#..#.
      ########.#
      ##...##.#.
      ..###.#.#.

      Tile 2971:
      ..#.#....#
      #...###...
      #.#.###...
      ##.##..#..
      .#####..##
      .#..####.#
      #..#.#..#.
      ..####.###
      ..#.#.###.
      ...#.#.#.#

      Tile 2729:
      ...#.#.#.#
      ####.#....
      ..#.#.....
      ....#..#.#
      .##..##.#.
      .#.####...
      ####.#.#..
      ##.####...
      ##..#.##..
      #.##...##.

      Tile 3079:
      #.#.#####.
      .#..######
      ..#.......
      ######....
      ####.#..#.
      .#...#.##.
      #.#####.##
      ..#.###...
      ..#.......
      ..#.###...
    INPUT
  end

  before { allow(Advent::Day20).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 20899048083289 }
  end

  describe 'part 2' do
    subject { day.solve part: 2 }
    it { is_expected.to eq 273 }
  end

  describe Advent::Day20::ImageAssembler do
    describe "tile ids" do
      subject { day.image_assembler.rows.map { |row| row.map(&:id) } }
      it { is_expected.to match_array([
        [1951, 2311, 3079],
        [2729, 1427, 2473],
        [2971, 1489, 1171],
      ]) }
    end

    describe "grid" do
      let(:grid) { day.image_assembler.grid }
      let(:expected_grid) { representation.split("\n").map(&:chars) }
      let(:representation) do
        <<~GRID
          .#.#..#.##...#.##..#####
          ###....#.#....#..#......
          ##.##.###.#.#..######...
          ###.#####...#.#####.#..#
          ##.#....#.##.####...#.##
          ...########.#....#####.#
          ....#..#...##..#.#.###..
          .####...#..#.....#......
          #..#.##..#..###.#.##....
          #.####..#.####.#.#.###..
          ###.#.#...#.######.#..##
          #.####....##..########.#
          ##..##.#...#...#.#.#.#..
          ...#..#..#.#.##..###.###
          .#.#....#.##.#...###.##.
          ###.#...#..#.##.######..
          .#.#.###.##.##.#..#.##..
          .####.###.#...###.#..#.#
          ..#.#..#..#.#.#.####.###
          #..####...#.#.#.###.###.
          #####..#####...###....##
          #.##..#..#...#..####...#
          .#.###..##..##..####.##.
          ...###...##...#...#..###
        GRID
      end

      it "has the right number of rows" do
        expect(grid.size).to eq expected_grid.size
      end

      it "has the right number of columns" do
        expect(grid.map(&:size)).to eq expected_grid.map(&:size)
      end

      it "up to symmetry it is the same as the representation" do
        expect(Advent::Day20::GridOperations.ref_0(grid, 24)).to eq expected_grid
      end
    end
  end

  describe Advent::Day20::TileConfiguration do
    describe ".determine_from" do
      subject { described_class.determine_from(label, ref) }

      context "when label is east and ref is east" do
        let(:label) { :east }
        let(:ref) { :east }
        it { is_expected.to eq described_class.default.zip(described_class.default).to_h }
      end

      context "when label is east and ref is west" do
        let(:label) { :east }
        let(:ref)  { :west }
        it { is_expected.to eq({
          :east => :west,
          :west => :east,
          :north => :nORTH,
          :south => :sOUTH,
        }) }
      end

      context "when label is east and ref is eAST" do
        let(:label) { :east }
        let(:ref) { :eAST }
        it { is_expected.to eq({
          :east => :eAST,
          :west => :wEST,
          :north => :south,
          :south => :north,
        }) }
      end

      context "when label is east and ref is wEST" do
        let(:label) { :east }
        let(:ref) { :wEST }
        it { is_expected.to eq({
          :east => :wEST,
          :west => :eAST,
          :north => :sOUTH,
          :south => :nORTH,
        }) }
      end
    end
  end
end

