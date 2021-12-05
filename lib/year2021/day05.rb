require "solver"
require "set"

module Year2021
  class Day05 < Solver
    REGEX = /(?<x1>\d+),(?<y1>\d+) -> (?<x2>\d+),(?<y2>\d+)/

    def solve(part:)
      case part
      when 1 then intersection_points.count { |key, value| value }
      when 2 then intersection_points.size
      end
    end

    def cloud_lines
      @cloud_lines ||= lines.map do |line|
        match = REGEX.match(line)

        x1 = match[:x1].to_i
        y1 = match[:y1].to_i

        x2 = match[:x2].to_i
        y2 = match[:y2].to_i

        if x1 == x2
          VerticalLine.new(x: x1, y1: y1, y2: y2)
        elsif y1 == y2
          HorizontalLine.new(y: y1, x1: x1, x2: x2)
        else
          DiagonalLine.new(x1: x1, y1: y1, x2: x2, y2: y2)
        end
      end
    end

    def intersection_points
      @intersection_points ||= cloud_lines.combination(2).reduce(Hash.new) do |hash, (line, other)|
        line.intersect(other).each { |point| hash[point] ||= [line, other].none?(&:diagonal?) }
        hash
      end
    end

    module Intersection
      def intersect(line)
        return intersect_vertical(line) if line.is_a?(VerticalLine)
        return intersect_horizontal(line) if line.is_a?(HorizontalLine)
        intersect_diagonal(line)
      end

      def intersect_colinear(a_min, a_max, b_min, b_max)
        min = [a_min, b_min].max
        max = [a_max, b_max].min
        (min..max)
      end
    end

    class VerticalLine
      include Intersection

      attr_reader :x, :y1, :y2

      def initialize(x:, y1:, y2:)
        @x = x
        @y1 = y1
        @y2 = y2
      end

      def diagonal?
        false
      end

      def intersect_vertical(line)
        return [] unless @x == line.x
        intersect_colinear(*vals, *line.vals).map { |y| [@x, y] }
      end

      def intersect_horizontal(line)
        return [] unless line.y.between?(*vals)
        return [] unless @x.between?(*line.vals)

        [[@x, line.y]]
      end

      def intersect_diagonal(line)
        line.intersect_vertical(self)
      end

      def vals
        @vals ||= [@y1, @y2].minmax
      end
    end

    class HorizontalLine
      include Intersection

      attr_reader :y, :x1, :x2

      def initialize(y:, x1:, x2:)
        @y = y
        @x1 = x1
        @x2 = x2
      end

      def diagonal?
        false
      end

      def intersect_vertical(line)
        line.intersect_horizontal(self)
      end

      def intersect_horizontal(line)
        return [] unless @y == line.y
        intersect_colinear(*vals, *line.vals).map { |x| [x, @y] }
      end

      def intersect_diagonal(line)
        line.intersect_horizontal(self)
      end

      def vals
        @vals ||= [@x1, @x2].minmax
      end
    end

    class DiagonalLine
      include Intersection

      attr_reader :x1, :x2, :y1, :y2

      def initialize(x1:, y1:, x2:, y2:)
        @x1 = x1
        @y1 = y1
        @x2 = x2
        @y2 = y2
      end

      def slope
        @slope ||= (@y2 - @y1) / (@x2 - @x1)
      end

      def intercept
        @intercept ||= @y1 - slope * @x1
      end

      def get_x(_y)
        (_y - intercept) / slope
      end

      def get_y(_x)
        _x * slope + intercept
      end

      def diagonal?
        true
      end

      def intersect_vertical(line)
        return [] unless line.x.between?(*x_vals) && get_y(line.x).between?(*line.vals)
        [[line.x, get_y(line.x)]]
      end

      def intersect_horizontal(line)
        return [] unless line.y.between?(*y_vals) && get_x(line.y).between?(*line.vals)
        [[get_x(line.y), line.y]]
      end

      def intersect_diagonal(line)
        return intersect_parallel_diagonal(line) if slope == line.slope
        intersect_perpendicular_diagonal(line)
      end

      def intersect_parallel_diagonal(line)
        return [] unless intercept == line.intercept
        intersect_colinear(*x_vals, *line.x_vals).map { |_x| [_x, get_y(_x)] }
      end

      def intersect_perpendicular_diagonal(line)
        return [] unless (intercept + line.intercept) % 2 == 0

        _y = (intercept + line.intercept) / 2
        return [] unless _y.between?(*y_vals) && _y.between?(*line.y_vals)
        [[get_x(_y), _y]]
      end

      def x_vals
        @x_vals ||= [@x1, @x2].minmax
      end

      def y_vals
        @y_vals ||= [@y1, @y2].minmax
      end
    end
  end
end
