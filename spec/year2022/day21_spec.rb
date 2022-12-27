require "year2022/day21"

describe Year2022::Day21 do
  let(:day) { Year2022::Day21.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      root: pppw + sjmn
      dbpl: 5
      cczh: sllz + lgvd
      zczc: 2
      ptdq: humn - dvpt
      dvpt: 3
      lfqf: 4
      humn: 5
      ljgn: 2
      sjmn: drzm * dbpl
      sllz: 4
      pppw: cczh / lfqf
      lgvd: ljgn * ptdq
      drzm: hmdt - zczc
      hmdt: 32
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 152 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 301 }
  end
end
