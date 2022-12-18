require "set"
require "solver"
require "vector"

module Year2022
  class Day18 < Solver
    def solve(part:)
      case part
      when 1 then naive_surface_area
      when 2 then surface_area
      end
    end

    def lava_cubes
      @lava_cubes ||= Set.new(
        lines.map { |line| Cube.new(line.split(",").map(&:to_i)) },
      )
    end

    def lava_neighbors_count
      lava_cubes.to_a.combination(2).sum do |(cube, other)|
        cube.neighbor?(other) ? 1 : 0
      end
    end

    def naive_surface_area
      @naive_surface_area ||= 6 * lava_cubes.size - 2 * lava_neighbors_count
    end

    def bounding_box
      BoundingBox.new(lava_cubes).build
    end

    def surface_area
      naive_surface_area - bounding_box.interior_edge_count
    end

    class BoundingBox
      attr_reader :points

      def initialize(lava_cubes)
        @lava_cubes = lava_cubes
        @exterior = Set.new
        @visited = Set.new
        @frontier = [start]
      end

      def start
        Cube.new(ranges.map(&:first))
      end

      def advance
        @frontier.pop.tap do |cube|
          return unless @visited.add?(cube)
          if in_range?(cube) && !@lava_cubes.include?(cube)
            @exterior << cube.point
          end
          neighbors(cube).each { |neighbor| @frontier << neighbor }
        end
      end

      def build
        advance until @frontier.empty?
        self
      end

      def neighbors(cube)
        cube.neighbors.select do |neighbor|
          in_range?(neighbor) &&
            !@lava_cubes.include?(neighbor) &&
            !@visited.include?(neighbor)
        end
      end

      def points
        ranges.drop(1).reduce(ranges.first.to_a) do |acc, range|
          acc.product(range.to_a)
        end.map(&:flatten)
      end

      def interior
        points.reject do |point|
          @exterior.include?(point) || @lava_cubes.include?(Cube.new(point))
        end
      end

      def interior_edge_count
        interior.sum do |point|
          Cube.new(point).neighbors.count { |neighbor| @lava_cubes.include?(neighbor) }
        end
      end

      def in_range?(cube)
        cube.point.zip(ranges).all? do |coord, range|
          coord.between?(*range.minmax)
        end
      end

      def range_for(index)
        min, max = @lava_cubes.map { |cube| cube.point[index] }.minmax
        (min - 1..max + 1)
      end

      def ranges
        @ranges ||= (0..2).map(&method(:range_for))
      end
    end

    class Cube < Struct.new(:point)
      def neighbors
        [1, 0, 0]
          .permutation
          .uniq
          .flat_map do |direction|
            [-1, 1].map do |sign|
              Cube.new(Vector.add(point, Vector.scale(direction, sign)))
            end
          end
      end

      def neighbor?(other)
        Vector.distance(point, other.point) == 1
      end
    end
  end
end
