require "year2021/day08"

describe Year2021::Day08 do
  let(:day) { Year2021::Day08.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW
      be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
      edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
      fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
      fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
      aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
      fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
      dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
      bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
      egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
      gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
    RAW
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 26 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 61229 }
  end

  describe "entry" do
    let(:line) { "acedgfb cdfbe gcdfa fbcad dab cefabd cdfgeb eafb cagedb ab | cdfeb fcadb cdfeb cdbaf" }
    let(:entry) { Year2021::Day08::Entry.new(line) }

    it "decodes as deafgbc" do
      expect(entry.decode).to eq({
        :a => "d",
        :b => "e",
        :c => "a",
        :d => "f",
        :e => "g",
        :f => "b",
        :g => "c",
      })
    end

    it "has 5353 as output" do
      expect(entry.output).to eq 5353
    end
  end
end
