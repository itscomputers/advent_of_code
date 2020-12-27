require 'year2019/intcode_computer'

describe IntcodeComputer do
  let(:computer) { IntcodeComputer.new program }
  let(:memory) { computer.run.memory }

  describe "opcodes 3 and 4" do
    let(:input) { Random.rand(69..666) }
    let(:program) { [3, 0, 4, 0, 99] }

    it "writes the input to the output" do
      computer.input = input
      computer.run
      expect(computer.memory).to eq [input, 0, 4, 0, 99]
      expect(computer.output).to eq input
    end
  end

  describe 'example 1' do
    let(:program) { [1002, 4, 3, 4, 33] }
    it { expect(memory).to eq [1002, 4, 3, 4, 99] }
  end

  describe 'example 2' do
    let(:program) { [3,9,8,9,10,9,4,9,99,-1,8] }

    it "outputs 1 when the input is 8" do
      computer.input = 8
      expect(computer.run.output).to eq 1
    end

    it "ouputs 0 when the input is not 8" do
      computer.input = 10
      expect(computer.run.output).to eq 0
    end
  end

  describe 'example 3' do
    let(:program) { [3,9,7,9,10,9,4,9,99,-1,8] }

    it "outputs 1 when the input is < 8" do
      computer.input = 5
      expect(computer.run.output).to eq 1
    end

    it "ouputs 0 when the input is not < 8" do
      computer.input = 8
      expect(computer.run.output).to eq 0
    end
  end

  describe 'example 4' do
    let(:program) { [3,3,1108,-1,8,3,4,3,99] }

    it "outputs 1 when the input is 8" do
      computer.input = 8
      expect(computer.run.output).to eq 1
    end

    it "ouputs 0 when the input is not 8" do
      computer.input = 10
      expect(computer.run.output).to eq 0
    end
  end

  describe 'example 5' do
    let(:program) { [3,3,1107,-1,8,3,4,3,99] }

    it "outputs 1 when the input is < 8" do
      computer.input = 5
      expect(computer.run.output).to eq 1
    end

    it "ouputs 0 when the input is not < 8" do
      computer.input = 8
      expect(computer.run.output).to eq 0
    end
  end

  describe 'example 6' do
    let(:program) { [3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9] }

    it "outputs 0 if input is 0" do
      computer.input = 0
      expect(computer.run.output).to eq 0
    end

    it "outputs 1 if input is not 0" do
      computer.input = 69
      expect(computer.run.output).to eq 1
    end
  end

  describe 'example 7' do
    let(:program) { [3,3,1105,-1,9,1101,0,0,12,4,12,99,1] }

    it "outputs 0 if input is 0" do
      computer.input = 0
      expect(computer.run.output).to eq 0
    end

    it "outputs 1 if input is not 0" do
      computer.input = 69
      expect(computer.run.output).to eq 1
    end
  end

  describe 'example 8' do
    let(:program) { [
        3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
        1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
        999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99,
    ] }

    it "outputs 999 if input is less than 8" do
      computer.input = 5
      expect(computer.run.output).to eq 999
    end

    it "outputs 1000 if input is equal to 8" do
      computer.input = 8
      expect(computer.run.output).to eq 1000
    end

    it "outputs 1000 if input is greater than 8" do
      computer.input = 69
      expect(computer.run.output).to eq 1001
    end
  end
end

