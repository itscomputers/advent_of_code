require "solver"
require "vector"

module Year2021
  class Day17 < Solver
    def solve(part:)
      case part
      when 1 then y_max
      when 2 then successful_launch_count
      end
    end

    def target_area
      @target_area ||= TargetArea.from(lines.first)
    end

    def successful_launch?(velocity)
      !StepRange.new(velocity, *target_area.ranges).empty?
    end

    def v_y_min
      @v_y_min ||= target_area.y_range.min
    end

    def v_y_max
      @v_y_max ||= -target_area.y_range.min
    end

    def v_x_min
      @v_x_min ||= QuadraticFormula.new(1, 1, -2 * target_area.x_range.min).solutions.last.ceil
    end

    def v_x_max
      @v_x_max ||= target_area.x_range.max
    end

    def v_x
      @v_x
    end

    def y_max
      v_y = v_y_max
      loop do
        break if (v_x_min..v_x_max).any? do |v_x|
          successful_launch?([v_x, v_y]).tap do |bool|
            @v_x = v_x if bool
          end
        end
        v_y = v_y - 1
      end
      (v_y * (v_y + 1)) / 2
    end

    def successful_launch_count
      (v_y_min..v_y_max).sum do |v_y|
        (v_x_min..v_x_max).sum do |v_x|
          successful_launch?([v_x, v_y]) ? 1 : 0
        end
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

      def ranges
        [@x_range, @y_range]
      end
    end

    class StepRange
      def initialize(velocity, x_range, y_range)
        @v_x, @v_y = velocity
        @x_min = x_range.min
        @x_max = x_range.max
        @y_min = y_range.min
        @y_max = y_range.max
      end

      def lower_for_x
        if @v_x * (@v_x + 1) < 2 * @x_min
          nil
        else
          solutions_for_x_min.first.ceil
        end
      end

      def upper_for_x
        if @v_x * (@v_x + 1) < 2 * @x_max
          nil
        else
          solutions_for_x_max.first.floor
        end
      end

      def lower_for_y
        solutions_for_y_max.last.ceil
      end

      def upper_for_y
        solutions_for_y_min.last.floor
      end

      def empty?
        return true if lower_for_x.nil?
        return true if lower_for_y > upper_for_y
        return true if lower_for_x > upper_for_y
        return false if upper_for_x.nil?
        lower_for_y > upper_for_x
      end

      def solutions_for_x_min
        @solutions_for_x_min ||= QuadraticFormula.solutions_for(@v_x, @x_min)
      end

      def solutions_for_x_max
        @solutions_for_x_max ||= QuadraticFormula.solutions_for(@v_x, @x_max)
      end

      def solutions_for_y_min
        @solutions_for_y_min ||= QuadraticFormula.solutions_for(@v_y, @y_min)
      end

      def solutions_for_y_max
        @solutions_for_y_max ||= QuadraticFormula.solutions_for(@v_y, @y_max)
      end
    end

    class QuadraticFormula
      def self.solutions_for(velocity, value)
        new(1, -2 * velocity - 1, 2 * value).solutions
      end

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
        ].sort
      end

      def positive_solutions
        solutions.select { |solution| solution > 0 }
      end
    end
  end
end
