require "solver"

module Year2022
  class Day25 < Solver
    def solve(part:)
      case part
      when 1 then Snafu.from_i(snafus.sum(&:to_i))
      when 2 then "hooray!!"
      end
    end

    def snafus
      lines.map { |line| Snafu.new(line) }
    end

    class Snafu < String
      MAPPING = {
        -2 => "=",
        -1 => "-",
        0 => "0",
        1 => "1",
        2 => "2",
      }

      def self.digit(char)
        MAPPING.find { |_digit, ch| ch == char }.first
      end

      def self.from_i(number)
        return "" if number == 0
        quotient, remainder = number.divmod_with_small_remainder(5)
        [from_i(quotient), MAPPING[remainder]].join
      end

      def to_i
        chars.reverse.map.with_index do |char, index|
          Snafu.digit(char) * (5 ** index)
        end.sum
      end
    end
  end
end

class Integer
  def divmod_with_small_remainder(divisor)
    divmod(divisor).tap do |quotient, remainder|
      return [quotient + 1, remainder - divisor] if 2 * remainder > divisor
    end
  end
end
