require "solver"
require "vector"

module Year2021
  class Day17 < Solver
    def solve(part:)
      search
    end

    def target_area
      @target_area ||= TargetArea.from(lines.first)
    end

    class Search
      def initialize(target_area)
        @target_area = target_area
      end

      def x(vx, step)
        return vx * (step + 1) - triangular(step) if step < vx
        triangular(vx)
      end

      def y(vy, step)
        vy * (step + 1) - triangular(step)
      end

      def point(velocity, step)
        vx, vy = velocity
        [x(vx, step), y(vy, step)]
      end

      def triangular(number)
        (number * (number + 1)) / 2
      end

      def vx_min
        (-1 + Math.sqrt(1 + 8 * triangular(x_range.min)))
      end

      def vx_max
        x_range.max
      end

      def x_range
        @target_area.x_range
      end
    end

    class QuadraticSolutions
      def initialize(a, b, c)
        @a = a
        @b = b
        @c = c
      end

      def discriminant
        @b**2 - 4 * @a * @c
      end

      def solutions
        [
          (-@b + Math.sqrt(discriminant)) / 2,
          (-@b - Math.sqrt(discriminant)) / 2,
        ]
      end

      def positive_solutions
        solutions.select { |solution| solution > 0 }
      end
    end

    class TargetArea
      REGEX = /target area: x=(?<x1>[-]?\d+)\.\.(?<x2>[-]?\d+), y=(?<y1>[-]?\d+)\.\.(?<y2>[-]?\d+)/

      def self.from(line)
        match = REGEX.match(line)
        new(
          (match[:x1].to_i..match[:x2].to_i),
          (match[:y1].to_i..match[:y2].to_i),
        )
      end

      attr_reader :x_range, :y_range

      def initialize(x_range, y_range)
        @x_range = x_range
        @y_range = y_range
      end

      def include?(point)
        @x_range.include?(point.first) && @y_range.include?(point.last)
      end

      def out_of_range?(point)
        @y_range.min > point.last
      end
    end

    class Launcher
      def initialize(velocity, target_area)
        @point = [0, 0]
        @velocity = velocity
        @target_area = target_area
      end

      def launch
        advance until in_target_area? || out_of_range?
        self
      end

      def advance
        @point = Vector.add(@point, @velocity)
        @velocity = Vector.add(@velocity, [drag, -1])
      end

      def drag
        case @velocity.first
        when 1.. then -1
        when ..-1 then 1
        else 0
        end
      end

      def in_target_area?
        @target_area.include?(@point)
      end
      alias_method :successful?, :in_target_area?

      def out_of_range?
        @target_area.out_of_range?(@point)
      end
    end
  end
end
