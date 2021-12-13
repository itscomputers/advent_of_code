require "year2021/day13"

describe Year2021::Day13 do
  let(:raw_input) do
    <<~RAW
      6,10
      0,14
      9,10
      0,3
      10,4
      4,11
      6,0
      6,12
      4,1
      0,13
      10,12
      3,4
      3,0
      8,4
      1,10
      2,14
      8,10
      9,0

      fold along y=7
      fold along x=5
    RAW
  end
  let(:day) { Year2021::Day13.new(raw_input) }

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 17 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it do
      expect(subject.strip).to eq <<~RAW.strip
        #####
        #...#
        #...#
        #...#
        #####
      RAW
    end
  end
end
