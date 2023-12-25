require "year2023/day20"

describe Year2023::Day20 do
  let(:day) { Year2023::Day20.new }
  let(:input1) do <<~INPUT
    broadcaster -> a, b, c
    %a -> b
    %b -> c
    %c -> inv
    &inv -> a
  INPUT
  end
  let(:input2) do <<~INPUT
    broadcaster -> a
    %a -> inv, con
    &inv -> b
    %b -> con
    &con -> output
  INPUT
  end

  before do
    allow(day).to receive(:raw_input).and_return input
  end

  describe "part 1" do
    subject { day.solve(part: 1) }

    context "input 1" do
      let(:input) { input1}
      it { is_expected.to eq 32000000 }
    end

    context "input 2" do
      let(:input) { input2}
      it { is_expected.to eq 11687500 }
    end
  end
end
