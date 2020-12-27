require 'year2019/intcode_computer'

describe IntcodeComputer do
  let(:computer) { IntcodeComputer.new program }
  let(:program) { [opcode, 5, 1, 4, 2, 3] }
  let(:opcode) { 1 }

  describe '#set and #get' do
    it 'can set position 2 to 1000' do
      expect(computer.memory[2]).to_not eq 1000
      expect(computer.get 2).to_not eq 1000
      computer.set 2, 1000
      expect(computer.get 2).to eq 1000
      expect(computer.memory[2]).to eq 1000
    end

    it 'can set position 500 to 1000' do
      expect(computer.memory[500]).to be_nil
      expect(computer.get 500).to eq 0
      computer.set 500, 1000
      expect(computer.get 500).to eq 1000
      expect(computer.memory[500]).to eq 1000
    end
  end

  let(:memory) { computer.advance.memory }
  let(:address) { computer.advance.address }

  describe '#add' do
    let(:opcode) { 1 }
    it { expect(memory).to eq [opcode, 5, 1, 4, 5 + 3, 3] }
    it { expect(address).to eq 4 }
  end

  describe '#multiply' do
    let(:opcode) { 2 }
    subject { computer.advance.memory }
    it { expect(memory).to eq [opcode, 5, 1, 4, 5 * 3, 3] }
    it { expect(address).to eq 4 }
  end




# describe 'add' do
#   [
#     { :program => [   1, 5, 1, 4, 2, 3], :result => 3 + 5 },
#     { :program => [ 101, 5, 1, 4, 2, 3], :result => 5 + 5 },
#     { :program => [1101, 5, 1, 4, 2, 3], :result => 5 + 1 },
#     { :program => [1001, 5, 1, 4, 2, 3], :result => 3 + 1 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and advanced pointer" do
#         computer.advance
#         expect(computer.get 4).to eq hash[:result]
#         expect(computer.pointer).to eq 4
#       end
#     end
#   end
# end

# describe 'multiply' do
#   [
#     { :program => [   2, 5, 1, 4, 2, 3], :result => 3 * 5 },
#     { :program => [ 102, 5, 1, 4, 2, 3], :result => 5 * 5 },
#     { :program => [1102, 5, 1, 4, 2, 3], :result => 5 * 1 },
#     { :program => [1002, 5, 1, 4, 2, 3], :result => 3 * 1 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and advanced pointer" do
#         computer.advance
#         expect(computer.get 4).to eq hash[:result]
#         expect(computer.pointer).to eq 4
#       end
#     end
#   end
# end

# describe 'write_from_input' do
#   [
#     { :program => [   3, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [ 103, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [1103, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [1003, 5, 1, 4, 2, 3], :result => 666 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }
#       let(:inputs) { [666] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.get 5).to eq 666
#         expect(computer.pointer).to eq 2
#       end
#     end
#   end
# end

# describe 'write_from_default_input' do
#   [
#     { :program => [   3, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [ 103, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [1103, 5, 1, 4, 2, 3], :result => 666 },
#     { :program => [1003, 5, 1, 4, 2, 3], :result => 666 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }
#       let(:default_input) { 666 }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.get 5).to eq 666
#         expect(computer.pointer).to eq 2
#       end
#     end
#   end
# end

# describe 'write_to_output' do
#   [
#     { :program => [   4, 5,1,4,2,3], :result => 3 },
#     { :program => [ 104, 5,1,4,2,3], :result => 5 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.outputs).to eq [hash[:result]]
#         expect(computer.output).to eq hash[:result]
#         expect(computer.pointer).to eq 2
#       end
#     end
#   end
# end

# describe 'jump_if_true' do
#   [
#     { :program => [   5, 5,1,4,2,3], :result => 5 },
#     { :program => [ 105, 5,1,4,2,3], :result => 5 },
#     { :program => [1105, 5,1,4,2,3], :result => 1 },
#     { :program => [1005, 5,1,4,2,3], :result => 1 },
#     { :program => [   5, 5,1,4,2,0], :result => 3 },
#     { :program => [ 105, 0,1,4,2,3], :result => 3 },
#     { :program => [1105, 0,1,4,2,3], :result => 3 },
#     { :program => [1005, 5,1,4,2,0], :result => 3 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.pointer).to eq hash[:result]
#       end
#     end
#   end
# end

# describe 'jump_if_false' do
#   [
#     { :program => [   6, 5,1,4,2,0], :result => 5 },
#     { :program => [ 106, 0,1,4,2,3], :result => 0 },
#     { :program => [1106, 0,1,4,2,3], :result => 1 },
#     { :program => [1006, 5,1,4,2,0], :result => 1 },
#     { :program => [   6, 5,1,4,2,3], :result => 3 },
#     { :program => [ 106, 5,1,4,2,3], :result => 3 },
#     { :program => [1106, 5,1,4,2,3], :result => 3 },
#     { :program => [1006, 5,1,4,2,3], :result => 3 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.pointer).to eq hash[:result]
#       end
#     end
#   end
# end

# describe 'less_than' do
#   [
#     { :program => [   7, 5,1,4,2,3], :result => 1 },
#     { :program => [ 107, 1,5,4,2,3], :result => 1 },
#     { :program => [1107, 1,5,4,2,3], :result => 1 },
#     { :program => [1007, 5,4,4,2,3], :result => 1 },
#     { :program => [   7, 5,1,4,2,6], :result => 0 },
#     { :program => [ 107, 5,1,4,2,3], :result => 0 },
#     { :program => [1107, 5,1,4,2,3], :result => 0 },
#     { :program => [1007, 5,3,4,2,3], :result => 0 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.get 4).to eq hash[:result]
#       end
#     end
#   end
# end

# describe 'equals' do
#   [
#     { :program => [   8, 5,4,4,3,3], :result => 1 },
#     { :program => [ 108, 5,1,4,2,3], :result => 1 },
#     { :program => [1108, 5,5,4,2,3], :result => 1 },
#     { :program => [1008, 5,3,4,2,3], :result => 1 },
#     { :program => [   8, 5,1,4,2,6], :result => 0 },
#     { :program => [ 108, 5,4,4,2,3], :result => 0 },
#     { :program => [1108, 5,1,4,2,3], :result => 0 },
#     { :program => [1008, 5,1,4,2,3], :result => 0 },
#   ].each do |hash|
#     context "when program is #{hash[:program]}" do
#       let(:program) { hash[:program] }

#       it "has the correct result and pointer" do
#         computer.advance
#         expect(computer.get 4).to eq hash[:result]
#       end
#     end
#   end
# end

# describe 'specific cases' do
#   describe 'case 1' do
#     let(:program) { [1002, 4, 3, 4, 33] }

#     it "has updated current state" do
#       computer.run
#       expect(computer.current_state).to eq [1002, 4, 3, 4, 99]
#     end
#   end

#   describe 'case 2' do
#     let(:program) { [1101, 100, -1, 4, 0] }

#     it "has updated current state" do
#       computer.run
#       expect(computer.current_state).to eq [1101, 100, -1, 4, 99]
#     end
#   end

#   describe 'case 3' do
#     let(:program) { [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99] }

#     it "has updated current state" do
#       computer.run
#       expect(computer.outputs).to eq program
#     end
#   end
# end
end

