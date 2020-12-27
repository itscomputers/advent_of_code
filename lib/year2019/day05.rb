require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day05 < Solver
    def part_one
      computer_with(input: 1).run.output
    end

    def part_two
      computer_with(input: 5).run.output
    end

    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end

    def computer_with(input:)
      IntcodeComputer.new(program).tap do |computer|
        computer.input = input
      end
    end
  end
end

