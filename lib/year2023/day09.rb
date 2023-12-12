require "solver"

module Year2023
  class Day09 < Solver
    def solve(part:)
      case part
      when 1 then predictors.map(&:predict_right).sum
      when 2 then predictors.map(&:predict_left).sum
      else nil
      end
    end

    def predictors
      @predictors ||= lines.map { |line| Predictor.build(line) }
    end

    class Predictor
      def self.build(line)
        new(line.split(" ").map(&:to_i))
      end

      def initialize(sequence)
        @sequences = [sequence]
        differentiate!
      end

      def differentiate!
        until constant?(@sequences.last)
          @sequences << differences(@sequences.last)
        end
      end

      def constant?(sequence)
        sequence.all? { |val| val == sequence.first }
      end

      def differences(sequence)
        sequence.each_cons(2).map { |(val1, val2)| val2 - val1 }
      end

      def predict_right
        @sequences.map(&:last).sum
      end

      def predict_left
        @sequences.map(&:first).reverse.reduce(0) { |acc, val| val - acc }
      end
    end
  end
end
