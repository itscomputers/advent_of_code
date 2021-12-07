require "solver"

module Year2021
  class Day07 < Solver
    def solve(part:)
      alignment(part: part).cost
    end

    def alignment(part:)
      case part
      when 1 then LinearCrabAlignment.new(crab_positions)
      when 2 then QuadraticCrabAlignment.new(crab_positions)
      end
    end

    def crab_positions
      @crab_positions ||= lines.first.split(",").map(&:to_i).sort
    end

    class LinearCrabAlignment
      def initialize(positions)
        @positions = positions
      end

      def cost_for(alignment)
        @positions.sum { |position| (position - alignment).abs }
      end

      def optimal_alignment
        Range.new(*@positions.minmax).min_by(&method(:cost_for))
      end

      def cost
        cost_for(optimal_alignment)
      end
    end

    class QuadraticCrabAlignment < LinearCrabAlignment
      def cost_for(alignment)
        @positions.sum do |position|
          diff = (position - alignment).abs
          (diff * (diff + 1)) / 2
        end
      end
    end
  end
end
