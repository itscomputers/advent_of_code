require "year2022/day07"

describe Year2022::Day07 do
 let(:day) { Year2022::Day07.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      $ cd /
      $ ls
      dir a
      14848514 b.txt
      8504156 c.dat
      dir d
      $ cd a
      $ ls
      dir e
      29116 f
      2557 g
      62596 h.lst
      $ cd e
      $ ls
      584 i
      $ cd ..
        $ cd ..
        $ cd d
      $ ls
      4060174 j
      8033020 d.log
      5626152 d.ext
      7214296 k
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 95437 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 24933642 }
  end
end
