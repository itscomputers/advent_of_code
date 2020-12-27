require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day05 < Solver
    def part_one
      interface.reset.run_with(inputs: [1]).output
    end

    def part_two
      interface.reset.run_with(inputs: [5]).output
    end

    def program
      raw_input.chomp.split(",").map(&:to_i)
    end

    def interface
      @interface = IntcodeInterface.new program
    end
  end
end

