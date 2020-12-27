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
        @interface = IntcodeInterface.new program
      end

      def output_signal
        @output_signal ||= @sequence.reduce(0) do |output, input|
          @interface.reset.run(inputs: [input, output]).output
        end
      end
    end

    class AmplifierSetWithFeedback
      def initialize(sequence, program)
        @sequence = sequence
        @size = sequence.size
        @interfaces = @size.times.map do |index|
          IntcodeInterface.new(program).add_input @sequence[index]
        end
        @index = 0
      end

      def input
        prev_interface.output || 0
      end

      def interface_at(index)
        @interfaces[index % @size]
      end

      def interface
        interface_at @index
      end

      def prev_interface
        interface_at @index - 1
      end

      def output_signal
        until @interfaces.all? { |interface| interface.computer.halted? }
          interface.run_interactive { input }
          @index += 1
        end
        interface_at(4).output
      end
    end
  end
end

