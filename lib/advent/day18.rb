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

    def expressions
      @input.map { |string| Expression.new string.gsub(/ +/, "").chars }
    end

    def solve(part:)
      case part
      when 1 then expressions.map(&:evaluate).sum
      when 2 then @input.map { |string| string.evaluate_with_modified_order_of_operations }.sum
      end
    end

    class Expression
      attr_reader :chars

      def initialize(chars)
        @chars = chars
        simplify_chars!
      end

      def sub_expression_indeces
        @sub_expression_indeces ||= begin
          parentheses_count = 0
          indeces = []

          @chars.each_with_index do |char, index|
            if char == "("
              if parentheses_count == 0
                @start_index = index
              end
              parentheses_count += 1
            elsif char == ")"
              if parentheses_count == 1
                indeces << [@start_index, index]
              end
              parentheses_count -= 1
            end
          end

          indeces
        end
      end

      def simplify_chars!
        return self if sub_expression_indeces.empty?

        @index = 0
        chars = sub_expression_indeces.reduce(Array.new) do |array, (i0, i1)|
          [
            *array,
            *@chars[@index...i0],
            self.class.new(@chars[(i0+1)...i1]).evaluate,
          ].tap { @index = i1 + 1 }
        end
        @chars = [*chars, *@chars[@index..]]
        self
      end

      def evaluate
        value = @chars.shift
        @chars.each_slice(2).reduce(value) do |acc, (op, val)|
          eval [acc, op, val].join("")
        end
      end
    end
  end
end

class ModifiedInteger < Struct.new(:value)
  def +(other)
    self.class.new(value * other.value)
  end

  def *(other)
    self.class.new(value + other.value)
  end
end

class String
  def evaluate_with_modified_order_of_operations
    eval(
      gsub(/[+*]/, "+" => "*", "*" => "+")
      .gsub(/\d+/) { |val| "ModifiedInteger.new(#{val})" }
    ).value
  end
end

