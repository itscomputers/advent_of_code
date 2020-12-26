require 'solver'

module Year2020
  class Day18 < Solver
    def lines
      @lines ||= raw_input.split("\n")
    end

    def solve(part:)
      case part
      when 1 then lines.map(&method(:no_order_of_operations)).sum
      when 2 then lines.map(&method(:opposite_order_of_operations)).sum
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

