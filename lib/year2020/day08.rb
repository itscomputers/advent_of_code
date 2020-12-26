require 'solver'

module Year2020
  class Day08 < Solver
    def part_one
      console.run.accumulator
    end

    def part_two
      hacked_console.accumulator
    end

    def instruction_regex
      @instruction_regex ||= /^(?<operation>\w+) (?<argument>[\+\-]\d+)$/
    end

    def parse_line(line)
      match = instruction_regex.match line
      Instruction.new match[:operation], match[:argument]
    end

    def instructions
      parsed_lines
    end

    def console
      @console ||= GameConsole.new instructions
    end

    def hacked_console
      multiverse_instructions.each do |instructions|
        console = GameConsole.new instructions
        unless console.run.loop_found?
          return console
        end
      end
    end

    def multiverse_instructions
      instructions.map.with_index do |instruction, index|
        unless instruction.operation == 'acc'
          alt_universe_instructions_at index
        end
      end.compact
    end

    def alt_universe_instructions_at(index)
      [
        *instructions.take(index),
        instructions[index].opposite,
        *instructions.drop(index + 1),
      ]
    end

    class GameConsole
      attr_reader :accumulator

      def initialize(instructions)
        @instructions = instructions
        @accumulator = 0
        @pointer = 0
        @visited = Set.new
      end

      def instruction
        @instructions[@pointer]
      end

      def run
        advance until loop_found? || completed?
        self
      end

      def loop_found?
        @visited.include? @pointer
      end

      def completed?
        instruction.nil?
      end

      def advance
        @visited.add @pointer
        @accumulator, @pointer = instruction.execute @accumulator, @pointer
      end
    end

    class Instruction
      attr_reader :operation, :argument

      def initialize(operation, argument)
        @operation = operation
        @argument = argument.to_i
      end

      def execute(accumulator, pointer)
        case @operation
        when 'acc' then [accumulator + @argument, pointer + 1]
        when 'jmp' then [accumulator, pointer + @argument]
        when 'nop' then [accumulator, pointer + 1]
        end
      end

      def opposite
        self.class.new(opposite_operation, @argument)
      end

      def opposite_operation
        case @operation
        when 'jmp' then 'nop'
        when 'nop' then 'jmp'
        when 'acc' then 'acc'
        end
      end
    end
  end
end

