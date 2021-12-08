require "solver"

module Year2021
  class Day08 < Solver
    def solve(part:)
      case part
      when 1 then entries.sum { |entry| entry.outputs.count(&:easy?) }
      when 2 then entries.sum(&:output)
      end
    end

    def entries
      @entries ||= lines.map { |line| Entry.new(line) }
    end

    class Entry
      attr_reader :inputs, :outputs

      def initialize(line)
        inputs, outputs = line.split(" | ")
        @inputs = inputs.split.map { |string| ScrambledSignal.new(string) }
        @outputs = outputs.split.map { |string| @inputs.find { |input| input.has?(string.chars) } }
      end

      def output
        set_values!
        @outputs
          .map.with_index { |output, index| 10 ** (3 - index) * output.value }
          .sum
      end

      def decode
        {
          :a => a,
          :b => b,
          :c => c,
          :d => d,
          :e => e,
          :f => f,
          :g => g,
        }
      end

      def set_values!
        decode
        [zero, two, three, five, six, nine]
      end

      private

      def one
        @one ||= @inputs.find(&:one?)
      end

      def four
        @four ||= @inputs.find(&:four?)
      end

      def seven
        @seven ||= @inputs.find(&:seven?)
      end

      def eight
        @eight ||= @inputs.find(&:eight?)
      end

      def zero_six_nine
        @inputs.select(&:zero_six_nine?)
      end

      def two_three_five
        @inputs.select(&:two_three_five?)
      end

      def find_and_set(chars, value)
        @inputs.find { |entry| entry.has?(chars) }.tap { |entry| entry.value = value }
      end

      def zero
        @zero ||= find_and_set([a, b, c, e, f, g], 0)
      end

      def two
        @two ||= find_and_set([a, c, d, e, g], 2)
      end

      def three
        @three  ||= find_and_set([a, c, d, f, g], 3)
      end

      def five
        @five ||= find_and_set([a, b, d, f, g], 5)
      end

      def six
        @six ||= find_and_set([a, b, d, e, f, g], 6)
      end

      def nine
        @nine ||= find_and_set([a, b, c, d, f, g], 9)
      end

      def complement(chars)
        "abcdefg".chars - chars
      end

      def c_f
        one.chars
      end

      def b_c_d_f
        four.chars
      end

      def a_c_f
        seven.chars
      end

      def a_b_f_g
        zero_six_nine.map(&:chars).reduce(:&)
      end

      def a_d_g
        two_three_five.map(&:chars).reduce(:&)
      end

      def c_d_e
        complement(a_b_f_g)
      end

      def a
        (a_c_f - c_f).first
      end

      def b
        (a_b_f_g - a_d_g - a_c_f).first
      end

      def c
        (c_f - a_b_f_g).first
      end

      def d
        (a_d_g - a_b_f_g).first
      end

      def e
        (c_d_e - c_f - a_d_g).first
      end

      def f
        (c_f - [c]).first
      end

      def g
        (a_d_g - a_c_f - b_c_d_f).first
      end
    end

    class ScrambledSignal
      attr_reader :string
      attr_accessor :value

      def initialize(string)
        @string = string
        set_easy_value
      end

      def easy?
        [one?, four?, seven?, eight?].any?
      end

      def set_easy_value
        @value = 1 if one?
        @value = 4 if four?
        @value = 7 if seven?
        @value = 8 if eight?
      end

      def zero_six_nine?
        @string.length == 6
      end

      def two_three_five?
        @string.length == 5
      end

      def one?
        @string.length == 2
      end

      def four?
        @string.length == 4
      end

      def seven?
        @string.length == 3
      end

      def eight?
        @string.length == 7
      end

      def chars
        @chars ||= @string.chars.sort
      end

      def has?(other_chars)
        chars == other_chars.sort
      end
    end
  end
end
