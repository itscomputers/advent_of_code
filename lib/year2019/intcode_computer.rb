class IntcodeComputer
  attr_reader :memory, :address, :outputs

  def self.run(program, inputs: [])
    new(program).add_input(*inputs).run
  end

  def initialize(program)
    @memory = program.dup
    @address = 0
    @inputs = []
    @outputs = []
    @relative_base = 0
  end

  def inspect
    display = halted? ? "halted" : "instruction: #{[opcode, *raw_params]}"
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

  def output
    @outputs.last
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

  def next_output(&block)
    advance until will_output? || halted?
    unless halted?
      advance
      block.call self unless block.nil?
    end
    output
  end

  def next_input(&block)
    advance until requires_input? || halted?
    unless halted?
      block.call self unless block.nil?
      advance
    end
    self
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

  private

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
    when 9 then relative_base_offset
    when 99 then halt
    end
  end

  def params_shape
    case @opcode
    when 1 then [2, 1]
    when 2 then [2, 1]
    when 3 then [0, 1]
    when 4 then [1, 0]
    when 5 then [2, 0]
    when 6 then [2, 0]
    when 7 then [2, 1]
    when 8 then [2, 1]
    when 9 then [1, 0]
    when 99 then [0, 0]
    end
  end

  def raw_opcode
    get @address
  end

  def opcode
    @opcode = raw_opcode % 100
  end

  def instruction_size
    params_shape.sum + 1
  end

  def instruction
    @memory.slice @address, instruction_size
  end

  def raw_params
    instruction.drop(1)
  end

  def input_params
    raw_params.take(params_shape.first).zip(modes).map do |(param, mode)|
      case mode
      when '1' then param
      when '2' then get(param + @relative_base)
      else get(param)
      end
    end
  end

  def output_address
    address = raw_params.drop(params_shape.first).take(params_shape.last).first
    case modes[instruction_size - 2]
    when '2' then address + @relative_base
    else address
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
    set(output_address, @inputs.shift)
  end

  def write_to_output
    @outputs << input_params.first
  end

  def jump_if_true
    jump if input_params.first != 0
  end

  def jump_if_false
    jump if input_params.first == 0
  end

  def less_than
    binary_boolean_operation(:<)
  end

  def equals
    binary_boolean_operation(:==)
  end

  def relative_base_offset
    @relative_base += input_params.first
  end

  def jump
    set_address input_params.last
    @already_moved = true
  end

  def halt
    @halted = true
  end

  def binary_operation(operation, &block)
    output = input_params.reduce(operation)
    unless block.nil?
      output = block.call output
    end
    set output_address, output
  end

  def binary_boolean_operation(operation)
    binary_operation(operation) { |output| (output && 1) || 0 }
  end
end

