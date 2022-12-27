require "year2022/day20"

describe Year2022::Day20 do
  let(:day) { Year2022::Day20.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      1
      2
      -3
      3
      -2
      0
      4
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 3 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 1623178306 }
  end

  describe "state after each move" do
    let(:file) { day.file.tap { |f| mix_count.times { f.move_next } } }
    subject { file.state }

    context "no mixing" do
      let(:mix_count) { 0 }
      it { is_expected.to eq [1, 2, -3, 3, -2, 0, 4] }
    end

    context "mixing 1 time" do
      let(:mix_count) { 1 }
      it { is_expected.to eq [2, 1, -3, 3, -2, 0, 4] }
    end

    context "mixing 2 times" do
      let(:mix_count) { 2 }
      it { is_expected.to eq [1, -3, 2, 3, -2, 0, 4] }
    end

    context "mixing 3 times" do
      let(:mix_count) { 3 }
      it { is_expected.to eq [1, 2, 3, -2, -3, 0, 4] }
    end

    context "mixing 4 times" do
      let(:mix_count) { 4 }
      it { is_expected.to eq [1, 2, -2, -3, 0, 3, 4] }
    end

    context "mixing 5 times" do
      let(:mix_count) { 5 }
      it { is_expected.to eq [1, 2, -3, 0, 3, 4, -2] }
    end

    context "mixing 6 times" do
      let(:mix_count) { 6 }
      it { is_expected.to eq [1, 2, -3, 0, 3, 4, -2] }
    end

    context "mixing 7 times" do
      let(:mix_count) { 7 }
      it { is_expected.to eq [1, 2, -3, 4, 0, 3, -2] }
    end
  end

  describe "grove_coordinates" do
    subject { day.file.mix.grove_coordinates }
    it { is_expected.to eq [4, -3, 2] }
  end
end
