class IntcodeComputer
  attr_reader :memory, :address

  def initialize(program)
    @memory = program
    @address = 0
  end

  def run
    advance until terminated?
    self
  end

  def advance
    execute
    move_address
    self
  end

  def terminated?
    @terminated || opcode.nil?
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

  #---------------------------
  # instruction execution

  def execute
    case opcode
    when 1 then add
    when 2 then multiply
    when 99 then halt
    end
  end

  def instruction_size
    case @opcode
    when 1 then 4
    when 2 then 4
    when 99 then 1
    end
  end

  def opcode
    @opcode = get @address
  end

  def instruction
    @memory.slice @address, instruction_size
  end

  def params
    instruction.drop 1
  end

  def add
    binary_operation :+
  end

  def multiply
    binary_operation :*
  end

  def halt
    @terminated = true
  end

  def binary_operation(operation)
    set params.last, params.take(2).map(&method(:get)).reduce(operation)
  end
end

