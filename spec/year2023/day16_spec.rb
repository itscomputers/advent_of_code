require "year2023/day16"

describe Year2023::Day16 do
  let(:day) { Year2023::Day16.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      .|...\\....
      |.-.\\.....
      .....|-...
      ........|.
      ..........
      .........\\
      ..../.\\\\..
      .-.-/..|..
      .|....-|.\\
      ..//.|....
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 46 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 51 }
  end
end
