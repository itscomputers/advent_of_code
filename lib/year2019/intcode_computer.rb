class IntcodeComputer
  attr_reader :memory, :address
  attr_accessor :input

  def initialize(program)
    @memory = program
    @address = 0
    @outputs = []
  end

  def run
    advance until terminated?
    self
  end

  def advance
    execute
    move_address unless already_moved?
    self
  end

  def terminated?
    @terminated || opcode.nil?
  end

  def output
    @outputs.last
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
    set(params.first, input || 0)
  end

  def write_to_output
    @outputs << moded_params.first
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
    @terminated = true
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

