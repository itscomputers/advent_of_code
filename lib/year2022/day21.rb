require "solver"

module Year2022
  class Day21 < Solver
    def solve(part:)
      case part
      when 1 then root_number
      when 2 then human_number
      end
    end

    def monkey_lookup
      @monkey_lookup ||= lines
        .map { |line| Monkey.build(line) }
        .map { |monkey| [monkey.id, monkey] }
        .to_h
    end

    def root_number
      eval(monkey_lookup["root"].stringify(monkey_lookup))
    end

    def human_number
      HumanCalculator.new(monkey_lookup).solve
    end

    class HumanCalculator
      def initialize(monkey_lookup)
        @monkey_lookup = monkey_lookup
        @monkey_lookup["humn"].value = "humn"
        @expression, number = @monkey_lookup["root"].monkey_ids.map do |id|
          @monkey_lookup[id].stringify(@monkey_lookup)
        end
        @number = eval(number)
        @value = 1.0
        @sign = sign
      end

      def value
        eval(@expression.gsub("humn", @value.to_s))
      end

      def difference
        value - @number
      end

      def sign
        difference < 0 ? -1 : 1
      end

      def solve
        @value *= 2 while sign == @sign
        min = @value / 2
        max = @value

        loop do
          return @value.to_i if difference == 0
          @value = (min + max) / 2
          if sign == @sign
            min = @value
          else
            max = @value
          end
        end
      end
    end

    class Monkey
      attr_accessor :id, :value, :monkey_ids, :operation

      def self.build(line)
        Builder.new(line).build
      end

      def initialize(id, value: nil, monkey_ids: nil, operation: nil)
        @id = id
        @value = value
        @monkey_ids = monkey_ids
        @operation = operation
      end

      def stringify(lookup)
        return value.to_s unless value.nil?
        "(#{monkey_ids.map { |id| lookup[id].stringify(lookup) }.join(operation)})"
      end

      class Builder
        def initialize(line)
          @line = line
        end

        def number_match
          @number_match ||= @line.match(/(?<id>\w+): (?<value>\d+)/)
        end

        def math_match
          @math_match ||= @line.match(/(?<id>\w+): (?<first>\w+) (?<operation>[\+\-\*\/]) (?<second>\w+)/)
        end

        def build
          if !number_match.nil?
            Monkey.new(
              number_match[:id],
              value: number_match[:value].to_i,
            )
          elsif !math_match.nil?
            Monkey.new(
              math_match[:id],
              monkey_ids: [math_match[:first], math_match[:second]],
              operation: math_match[:operation],
            )
          else
            raise "no match detected"
          end
        end
      end
    end
  end
end
