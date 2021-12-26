require "year2021/day12"

describe Year2021::Day12 do
  let(:day) { Year2021::Day12.new(raw_input) }
  let(:raw_input) do
    <<~RAW
      start-A
      start-b
      A-c
      A-b
      b-d
      A-end
      b-end
    RAW
  end

  describe "example 1" do
    describe "part 1" do
      subject { day.solve(part: 1) }
      it { is_expected.to eq 10 }
    end

    describe "part 2" do
      subject { day.solve(part: 2) }
      it { is_expected.to eq 36 }
    end
  end

  describe "example 2" do
    let(:raw_input) do
      <<~RAW
        dc-end
        HN-start
        start-kj
        dc-start
        dc-HN
        LN-dc
        HN-end
        kj-sa
        kj-HN
        kj-dc
      RAW
    end

    describe "part 1" do
      subject { day.solve(part: 1) }
      it { is_expected.to eq 19 }
    end

    describe "part 2" do
      subject { day.solve(part: 2) }
      it { is_expected.to eq 103 }
    end
  end
end
