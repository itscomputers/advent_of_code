require "year2023/day10"

describe Year2023::Day10 do
  let(:day) { Year2023::Day10.new }

  describe "part 1" do
    context "example 1" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          -L|F7
          7S-7|
          L|7||
          -L-J|
          L|-JF
        RAW_INPUT
      end

      subject { day.solve(part: 1) }
      it { is_expected.to eq 4 }
    end

    context "example 2" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          7-F7-
          .FJ|7
          SJLL7
          |F--J
          LJ.LJ
        RAW_INPUT
      end

      subject { day.solve(part: 1) }
      it { is_expected.to eq 8 }
    end
  end

  describe "part 2" do
    subject { day.solve(part: 2) }

    context "example 1" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          ...........
          .S-------7.
          .|F-----7|.
          .||.....||.
          .||.....||.
          .|L-7.F-J|.
          .|..|.|..|.
          .L--J.L--J.
          ...........
        RAW_INPUT
      end
      it { is_expected.to eq 4 }
    end

    context "example 2" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          .F----7F7F7F7F-7....
          .|F--7||||||||FJ....
          .||.FJ||||||||L7....
          FJL7L7LJLJ||LJ.L-7..
          L--J.L7...LJS7F-7L7.
          ....F-J..F7FJ|L7L7L7
          ....L7.F7||L7|.L7L7|
          .....|FJLJ|FJ|F7|.LJ
          ....FJL-7.||.||||...
          ....L---J.LJ.LJLJ...
        RAW_INPUT
      end
      it { is_expected.to eq 8 }
    end

    context "example 3" do
      before do
        allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
          FF7FSF7F7F7F7F7F---7
          L|LJ||||||||||||F--J
          FL-7LJLJ||||||LJL-77
          F--JF--7||LJLJ7F7FJ-
          L---JF-JLJ.||-FJLJJ7
          |F|F-JF---7F7-L7L|7|
          |FFJF7L7F-JF7|JL---7
          7-L-JL7||F7|L7F-7F7|
          L.L7LFJ|||||FJL7||LJ
          L7JLJL-JLJLJL--JLJ.L
        RAW_INPUT
      end
      it { is_expected.to eq 10 }
    end
  end
end
