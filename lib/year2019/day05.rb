require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day05 < Solver
    def part_one
      IntcodeComputer.run(program, inputs: [1]).output
    end

    def part_two
      IntcodeComputer.run(program, inputs: [5]).output
    end

    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end
  end
end

