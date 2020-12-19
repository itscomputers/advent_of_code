require 'advent/day19'

describe Advent::Day19 do
  let(:day) { Advent::Day19.build }
  let(:raw_input) do
    <<~INPUT
      0: 4 1 5
      1: 2 3 | 3 2
      2: 4 4 | 5 5
      3: 4 5 | 5 4
      4: "a"
      5: "b"

      ababbb
      bababa
      abbbab
      aaabbb
      aaaabbb
    INPUT
  end

  before { allow(Advent::Day19).to receive(:raw_input).and_return raw_input }

  describe "part 1" do
    subject { day.solve part: 1 }
    it { is_expected.to eq 2 }
  end

  describe "#rule_hash" do
    let(:rule_hash) { day.rule_hash }

    describe "types of rule" do
      subject { rule_hash.transform_values(&:class) }
      it { is_expected.to eq({
        0 => Advent::Day19::CompoundRule,
        1 => Advent::Day19::CompoundRule,
        2 => Advent::Day19::CompoundRule,
        3 => Advent::Day19::CompoundRule,
        4 => Advent::Day19::SimpleRule,
        5 => Advent::Day19::SimpleRule,
      }) }
    end

    describe 'rule#to_s' do
      subject { rule_hash.transform_values(&:to_s) }
      it { is_expected.to eq({
        0 => "(a((aa|bb)(ab|ba)|(ab|ba)(aa|bb))b)",
        1 => "((aa|bb)(ab|ba)|(ab|ba)(aa|bb))",
        2 => "(aa|bb)",
        3 => "(ab|ba)",
        4 => "a",
        5 => "b",
      }) }
    end

    describe 'rule#regex' do
      subject { rule_hash.transform_values(&:regex) }
      it { is_expected.to eq({
        0 => /^(a((aa|bb)(ab|ba)|(ab|ba)(aa|bb))b)$/,
        1 => /^((aa|bb)(ab|ba)|(ab|ba)(aa|bb))$/,
        2 => /^(aa|bb)$/,
        3 => /^(ab|ba)$/,
        4 => /^a$/,
        5 => /^b$/,
      }) }
    end
  end

  describe "part 2" do
    let(:raw_input) do
      <<~INPUT
        42: 9 14 | 10 1
        9: 14 27 | 1 26
        10: 23 14 | 28 1
        1: "a"
        11: 42 31
        5: 1 14 | 15 1
        19: 14 1 | 14 14
        12: 24 14 | 19 1
        16: 15 1 | 14 14
        31: 14 17 | 1 13
        6: 14 14 | 1 14
        2: 1 24 | 14 4
        0: 8 11
        13: 14 3 | 1 12
        15: 1 | 14
        17: 14 2 | 1 7
        23: 25 1 | 22 14
        28: 16 1
        4: 1 1
        20: 14 14 | 1 15
        3: 5 14 | 16 1
        27: 1 6 | 14 18
        14: "b"
        21: 14 1 | 1 14
        25: 1 1 | 1 14
        22: 14 14
        8: 42
        26: 14 22 | 1 20
        18: 15 15
        7: 14 5 | 1 21
        24: 14 1

        abbbbbabbbaaaababbaabbbbabababbbabbbbbbabaaaa
        bbabbbbaabaabba
        babbbbaabbbbbabbbbbbaabaaabaaa
        aaabbbbbbaaaabaababaabababbabaaabbababababaaa
        bbbbbbbaaaabbbbaaabbabaaa
        bbbababbbbaaaaaaaabbababaaababaabab
        ababaaaaaabaaab
        ababaaaaabbbaba
        baabbaaaabbaaaababbaababb
        abbbbabbbbaaaababbbbbbaaaababb
        aaaaabbaabaaaaababaa
        aaaabbaaaabbaaa
        aaaabbaabbaaaaaaabbbabbbaaabbaabaaa
        babaaabbbaaabaababbaabababaaab
        aabbbbbaabbbaaaaaabbbbbababaaaaabbaaabba
      INPUT
    end

    before { expect(day.solve part: 1).to eq 3 }

    subject { day.solve part: 2 }
    it { is_expected.to eq 12 }
  end
end

