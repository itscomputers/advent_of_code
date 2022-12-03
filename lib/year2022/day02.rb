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
      def initialize(their_shape, input)
        @their_shape = their_shape
        @input = input
      end

      def number
        %w(X Y Z).index(@input) + 1
      end

      def outcome
        case @their_shape
        when "A" then %w(Z X Y).index(@input) * 3
        when "B" then %w(X Y Z).index(@input) * 3
        when "C" then %w(Y Z X).index(@input) * 3
        end
      end

      def score
        number + outcome
      end
    end

    class RoundV2 < Round
      def outcome
        @outcome ||= %w(X Y Z).index(@input) * 3
      end

      def number
        case outcome
        when 0 then %w(B C A).index(@their_shape) + 1
        when 3 then %w(A B C).index(@their_shape) + 1
        when 6 then %w(C A B).index(@their_shape) + 1
        end
      end
    end
  end
end
