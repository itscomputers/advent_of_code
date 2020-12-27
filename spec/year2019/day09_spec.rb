require 'year2019/intcode_computer'

describe IntcodeComputer do
  let(:computer) { IntcodeComputer.new program.dup }
  let(:output) { computer.run.output }
  let(:outputs) { computer.run.outputs }

  describe 'example 1' do
    let(:program) { [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] }
    it { expect(outputs).to eq program }
  end

  describe 'example 2' do
    let(:program) { [1102,34915192,34915192,7,4,7,99,0] }
    it { expect(output.to_s.size).to eq 16 }
  end

  describe 'example 3' do
    let(:program) { [104,1125899906842624,99] }
    it { expect(output).to eq program[1] }
  end
end

