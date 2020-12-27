require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day09 < Solver
    def part_one
      interface.reset.run(inputs: [1]).output
    end

    def part_two
      interface.reset.run(inputs: [2]).output
    end

    def interface
      @interface ||= IntcodeInterface.new program
    end

    def program
      raw_input.chomp.split(",").map(&:to_i)
    end
  end
end

