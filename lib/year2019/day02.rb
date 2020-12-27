require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day02 < Solver
    def part_one
      IntcodeComputer.new(modified_program 1202).run.memory.first
    end

    def part_two
      100*noun + verb
    end

    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end

    def desired_output
      19690720
    end

    def noun
      return @noun unless @noun.nil?

      (0..99).each do |value|
        if too_big?(100 * value)
          return @noun = value - 1
        end
      end
    end

    def verb
      (0..99).each do |value|
        if too_big?(100 * noun + value)
          return value - 1
        end
      end
    end

    def too_big?(value)
      IntcodeComputer.new(modified_program value).run.memory.first > desired_output
    end

    def modified_program(value)
      [program.first, *value.divmod(100), *program.drop(3)]
    end
  end
end

