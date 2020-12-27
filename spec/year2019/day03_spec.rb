require 'year2019/day03'

describe Year2019::Day03 do
  let(:day) { Year2019::Day03.new }
  let(:raw_input_1) do
    <<~INPUT
      R8,U5,L5,D3
      U7,R6,D4,L4
    INPUT
  end
  let(:raw_input_2) do
    <<~INPUT
      R75,D30,R83,U83,L12,D49,R71,U7,L72
      U62,R66,U55,R34,D71,R55,D58,R83
    INPUT
  end
  let(:raw_input_3) do
    <<~INPUT
      R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51
      U98,R91,D20,R16,D67,R40,U7,R15,U6,R7
    INPUT
  end

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }

    context "example 1" do
      let(:raw_input) { raw_input_1 }
      it { is_expected.to eq 6 }
    end

    context "example 2" do
      let(:raw_input) { raw_input_2 }
      it { is_expected.to eq 159 }
    end

    context "example 3" do
      let(:raw_input) { raw_input_3 }
      it { is_expected.to eq 135 }
    end
  end

  describe 'part 2' do
    subject { day.solve part: 2 }

    context "example 1" do
      let(:raw_input) { raw_input_1 }
      it { is_expected.to eq 30 }
    end

    context "example 2" do
      let(:raw_input) { raw_input_2 }
      it { is_expected.to eq 610 }
    end

    context "example 3" do
      let(:raw_input) { raw_input_3 }
      it { is_expected.to eq 410 }
    end
  end
end

