require "solver"

module Year2021
  class Day03 < Solver
    def solve(part:)
      case part
      when 1 then gamma * epsilon
      when 2 then oxygen_generator_rating * co_2_scrubbing_rating
      end
    end

    def numbers
      @numbers ||= lines.map { |line| line.to_i(2) }
    end

    def bit_count
      @bit_count ||= lines.first.length
    end

    def gamma
      @gamma ||= bit_count.times.map do |exp|
        count = numbers.count { |number| number & 2**exp == 2**exp }
        (count == [count, numbers.count - count].max) ? 2**exp : 0
      end.sum
    end

    def epsilon
      2**bit_count - 1 - gamma
    end

    def oxygen_generator_rating
      OxygenFilter.new(numbers, bit_count).result
    end

    def co_2_scrubbing_rating
      CO2Filter.new(numbers, bit_count).result
    end

    class Filter
      def initialize(numbers, bit_count)
        @numbers = numbers
        @exp = bit_count - 1
      end

      def result
        advance while @numbers.count > 1
        @numbers.first
      end

      def advance
        one, zero = @numbers.partition { |number| number & 2**@exp == 2**@exp }
        @numbers = choose(one, zero)
        @exp = @exp - 1
      end

      def choose(one, zero)
        NotImplemented
      end
    end

    class OxygenFilter < Filter
      def choose(one, zero)
        [one, zero].max_by(&:count)
      end
    end

    class CO2Filter < Filter
      def choose(one, zero)
        [zero, one].min_by(&:count)
      end
    end
  end
end
