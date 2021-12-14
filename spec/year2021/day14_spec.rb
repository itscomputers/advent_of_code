require "year2021/day14"

describe Year2021::Day14 do
  let(:raw_input) do
    <<~RAW
      NNCB

      CH -> B
      HH -> N
      CB -> H
      NH -> C
      HB -> C
      HC -> B
      HN -> C
      NN -> C
      BH -> H
      NC -> B
      NB -> B
      BN -> B
      BB -> N
      BC -> B
      CC -> N
      CN -> C
    RAW
  end
  let(:day) { Year2021::Day14.new(raw_input) }

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 1588 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 2188189693529 }
  end
end
