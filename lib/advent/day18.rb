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

    def no_order_of_operations(string)
      eval(
        string
          .gsub("*", "-")
          .gsub(/\d+/) { |val| "SubtractIsMultiply.new(#{val})" }
      ).value
    end

    def opposite_order_of_operations(string)
      eval(
        string
          .gsub(/[+*]/, "+" => "*", "*" => "+")
          .gsub(/\d+/) { |val| "SwapAddAndMultiply.new(#{val})" }
      ).value
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

