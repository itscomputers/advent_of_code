require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day07 < Solver
    def part_one
      find_max (0..4), AmplifierSet
    end

    def part_two
      find_max (5..9), AmplifierSetWithFeedback
    end

    def find_max(range, amplifier_class)
      range.to_a.permutation(5).map do |sequence|
        amplifier_class.new(sequence, program).output_signal
      end.max
    end

    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end

    class AmplifierSet
      def initialize(sequence, program)
        @sequence = sequence
        @program = program
      end

      def output_signal
        @output_signal ||= @sequence.reduce(0) do |output, input|
          IntcodeComputer.run(@program, inputs: [input, output]).output
        end
      end
    end

    class AmplifierSetWithFeedback
      def initialize(sequence, program)
        @computers = sequence.map do |input|
          IntcodeComputer.new(program).add_input input
        end
        @computer_cycle = [@computers.last, *@computers].each_cons(2).cycle
      end

      def advance
        prev, curr = @computer_cycle.next
        curr.next_input { |computer| computer.add_input prev.output || 0 }.next_output
        self
      end

      def output_signal
        advance until @computers.all?(&:halted?)
        @computers.last.output
      end
    end
  end
end

