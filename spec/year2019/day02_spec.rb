require 'year2019/intcode_computer'

describe IntcodeComputer do
  let(:computer) { IntcodeComputer.new program }
  subject { computer.run.memory }

  context "example 1" do
    let(:program) { [1,9,10,3,2,3,11,0,99,30,40,50] }
    it { is_expected.to eq [3500,9,10,70,2,3,11,0,99,30,40,50] }
  end

  context "example 2" do
    let(:program) { [1,0,0,0,99] }
    it { is_expected.to eq [2,0,0,0,99] }
  end

  context "example 3" do
    let(:program) { [2,3,0,3,99] }
    it { is_expected.to eq [2,3,0,6,99] }
  end

  context "example 4" do
    let(:program) { [2,4,4,5,99,0] }
    it { is_expected.to eq [2,4,4,5,99,9801] }
  end

  context "example 5" do
    let(:program) { [1,1,1,4,99,5,6,0,99] }
    it { is_expected.to eq [30,1,1,4,2,5,6,0,99] }
  end
end

