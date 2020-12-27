class IntcodeInterface
  attr_reader :outputs

  def initialize(program)
    @program = program
    @outputs = []
  end

  def inspect
    "<IntcodeInterface #{computer.inspect} output: #{output}>"
  end

  def output
    @outputs.last
  end

  def computer
    @computer ||= IntcodeComputer.new @program.dup
  end

  def advance
    computer.advance
  end

  def next_output
    computer.next_output
  end

  def add_input(*values)
    computer.add_input *values
    self
  end

  def reset
    @computer = nil
    @outputs = []
    @inputs = []
    self
  end

  def run(inputs: [], &block)
    add_input *inputs
    until computer.halted?
      output = computer.next_output
      unless computer.halted?
        @outputs << output
        block.call(@outputs) unless block.nil?
      end
    end
    self
  end

  def run_interactive(inputs: [], &block)
    add_input *inputs
    until computer.will_output? || computer.halted?
      computer.advance_to_next_io
      if computer.requires_input?
        add_input(block.call).advance
      end
    end
    output = next_output
    @outputs << output unless computer.halted?
    self
  end
end

class IntcodeComputer
  attr_reader :memory, :address, :output

  def initialize(program)
    @memory = program
    @address = 0
    @inputs = []
  end

  def inspect
    display = halted? ? "halted" : "instruction: #{[opcode, *params]}"
    "<IntcodeComputer #{display}>"
  end

  def run
    advance until halted?
    self
  end

  def advance
    unless halted?
      execute
      move_address unless already_moved?
    end
    self
  end

  def advance_to_next_io
    advance until io? || halted?
  end

  def halted?
    @halted || opcode.nil? || instruction_size.nil?
  end

  def requires_input?
    opcode == 3 && @inputs.empty?
  end

  def will_output?
    opcode == 4
  end

  def io?
    requires_input? || will_output?
  end

  def next_output
    advance until will_output? || halted?
    advance
    output
  end

  def add_input(*values)
    @inputs += values
    self
  end

  #---------------------------
  # state management

  def set(index, value)
    @memory[index] = value
    self
  end

  def get(index)
    @memory[index] || 0
  end

  def set_address(index)
    @address = index
    self
  end

  def move_address_by(value)
    set_address @address + value
    self
  end

  def move_address
    move_address_by instruction_size if instruction_size
  end

  def already_moved?
    @already_moved
  end

  #---------------------------
  # instruction execution

  def execute
    @already_moved = false
    case opcode
    when 1 then add
    when 2 then multiply
    when 3 then write_from_input
    when 4 then write_to_output
    when 5 then jump_if_true
    when 6 then jump_if_false
    when 7 then less_than
    when 8 then equals
    when 99 then halt
    end
  end

  def instruction_size
    case @opcode
    when 1 then 4
    when 2 then 4
    when 3 then 2
    when 4 then 2
    when 5 then 3
    when 6 then 3
    when 7 then 4
    when 8 then 4
    when 99 then 1
    end
  end

  def raw_opcode
    get @address
  end

  def opcode
    @opcode = raw_opcode % 100
  end

  def instruction
    @memory.slice @address, instruction_size
  end

  def params
    instruction.drop(1)
  end

  def moded_params
    params.zip(modes).map do |(param, mode)|
      case mode
      when '1' then param
      else get(param)
      end
    end
  end

  def modes
    raw_opcode.to_s.reverse.chars.drop(2)
  end

  def add
    binary_operation :+
  end

  def multiply
    binary_operation :*
  end

  def write_from_input
    raise "requires input" if @inputs.empty?
    set(params.first, @inputs.shift)
  end

  def write_to_output
    @output = moded_params.first
  end

  def jump_if_true
    jump if moded_params.first != 0
  end

  def jump_if_false
    jump if moded_params.first == 0
  end

  def less_than
    binary_boolean_operation(:<)
  end

  def equals
    binary_boolean_operation(:==)
  end

  def jump
    set_address moded_params.last
    @already_moved = true
  end

  def halt
    @halted = true
  end

  def binary_operation(operation, &block)
    output_address = params.last
    output = moded_params.take(2).reduce(operation)
    unless block.nil?
      output = block.call output
    end
    set output_address, output
  end

  def binary_boolean_operation(operation)
    binary_operation(operation) { |output| (output && 1) || 0 }
  end
end

