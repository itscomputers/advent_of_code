require "solver"

module Year2022
  class Day02 < Solver
    def solve(part:)
      rounds(part: part).sum(&:score)
    end

    def rounds(part:)
      klass = part == 1 ? Round : RoundV2
      lines.map { |line| klass.new(*line.split(" ")) }
    end

    class Round
      def initialize(opp_shape, input)
        @opp_shape = opp_shape
        @input = input
      end

      def opp_index
        %w(A B C).index(@opp_shape)
      end

      def index
        @index ||= %w(X Y Z).index(@input)
      end

      def number
        index + 1
      end

      def outcome
        3 * %w(Z X Y).cycle(3).drop(opp_index).index(@input)
      end

      def score
        number + outcome
      end
    end

    class RoundV2 < Round
      def outcome
        index * 3
      end

      def number
        1 + %w(B C A).cycle(3).drop(2 * index).index(@opp_shape)
      end
    end
  end
end
