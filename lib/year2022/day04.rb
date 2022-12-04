require "solver"

module Year2022
  class Day04 < Solver
    def solve(part:)
      count(part: part)
    end

    def assignment_pairs
      @assignment_pairs ||= lines.map do |line|
        line.split(",").map do |assignment_string|
          Assignment.new(*assignment_string.split("-").map(&:to_i))
        end
      end
    end

    def count(part:)
      assignment_pairs.sum do |(assignment, other)|
        case part
        when 1 then assignment.redundant?(other)
        when 2 then assignment.overlap?(other)
        end ? 1 : 0
      end
    end

    class Assignment
      attr_reader :start, :stop

      def initialize(start, stop)
        @start = start
        @stop = stop
      end

      def inspect
        "<Assignment #{@start}-#{@stop}>"
      end
      alias_method :to_s, :inspect

      def subset?(other)
        @start >= other.start && @stop <= other.stop
      end

      def redundant?(other)
        subset?(other) || other.subset?(self)
      end

      def overlap?(other)
        @start <= other.stop && @stop >= other.start
      end
    end
  end
end
