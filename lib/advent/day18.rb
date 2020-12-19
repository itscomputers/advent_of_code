require 'advent/day'

module Advent
  class Day18 < Advent::Day
    DAY = "18"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then @input.map(&method(:no_order_of_operations)).sum
      when 2 then @input.map(&method(:opposite_order_of_operations)).sum
      end
    end

    def evaluate(string, pattern:, substitution:, klass:)
      eval(string.gsub(pattern, substitution).gsub(/\d+/) { |val| "#{klass}.new(#{val})" }).value
    end

    def no_order_of_operations(string)
      evaluate string,
        pattern: /\*/,
        substitution: { "*" => "-" },
        klass: SubtractIsMultiply
    end

    def opposite_order_of_operations(string)
      evaluate string,
        pattern: /[\*\+]/,
        substitution: { "+" => "*", "*" => "+" },
        klass: SwapAddAndMultiply
    end

    class SubtractIsMultiply < Struct.new(:value)
      def +(other)
        self.class.new(value + other.value)
      end

      def -(other)
        self.class.new(value * other.value)
      end
    end

    class SwapAddAndMultiply < Struct.new(:value)
      def +(other)
        self.class.new(value * other.value)
      end

      def *(other)
        self.class.new(value + other.value)
      end
    end
  end
end

