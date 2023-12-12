require "solver"
require "grid"
require "point"

module Year2023
  class Day11 < Solver
    def solve(part:)
      case part
      when 1 then galaxies(factor: 2).distances.sum
      when 2 then galaxies(factor: 1000000).distances.sum
      else nil
      end
    end

    def galaxies(factor:)
      Galaxies.build(lines, factor)
    end

    class Galaxies
      def self.build(lines, factor)
        new(
          Grid.parse(lines, as: :set) { "#" },
          lines.first.size,
          lines.size,
          factor,
        )
      end

      def initialize(points, x_max, y_max, factor)
        @points = points
        @x_range = (0..x_max)
        @y_range = (0..y_max)
        @factor = factor
      end

      def empty_rows
        @empty_rows ||= @y_range.select(&method(:empty_row?))
      end

      def empty_cols
        @empty_cols ||= @x_range.select(&method(:empty_col?))
      end

      def distance(points)
        Point.distance(*points) + extra_distance(points)
      end

      def extra_distance(points)
        (@factor - 1) * (empty_row_count(points) + empty_col_count(points))
      end

      def distances
        @points.to_a.combination(2).map(&method(:distance))
      end

      def empty_row_count(points)
        empty_rows.count { |y| between?(y, points.map(&:last)) }
      end

      def empty_col_count(points)
        empty_cols.count { |x| between?(x, points.map(&:first)) }
      end

      def between?(value, values)
        value.between?(*values.sort)
      end

      def empty_row?(y)
        @x_range.none? { |x| @points.include?([x, y]) }
      end

      def empty_col?(x)
        @y_range.none? { |y| @points.include?([x, y]) }
      end
    end
  end
end
