require "year2021/day17"

describe Year2021::Day17 do
  let(:raw_input) do
    <<~RAW
      target area: x=20..30, y=-10..-5
    RAW
  end

  let(:day) { Year2021::Day17.new(raw_input) }

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 0 }
  end

  describe "successful_launch?" do
    subject { day.successful_launch?(velocity) }

    context "when velocity is [7, 2]" do
      let(:velocity) { [7, 2] }
      it { is_expected.to be true }
    end

    context "when velocity is [6, 3]" do
      let(:velocity) { [6, 3] }
      it { is_expected.to be true }
    end

    context "when velocity is [9, 0]" do
      let(:velocity) { [9, 0] }
      it { is_expected.to be true }
    end

    context "when velocity is [17, 4]" do
      let(:velocity) { [17, 4] }
      it { is_expected.to be false }
    end
  end
end
