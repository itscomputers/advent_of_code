require "a_star"
require "graph"
require "grid"
require "point"
require "solver"

module Year2022
  class Day12 < Solver
    def solve(part:)
      case part
      when 1 then height_map.min_path_cost
      when 2 then height_maps.map(&:min_path_cost).compact.min
      end
    end

    def grid
      @grid ||= Grid.parse(lines, :as => :hash)
    end

    def height_map
      HeightMap.new(grid, start)
    end

    def start
      @start ||= grid.find { |point, char| char == "S" }.first
    end

    def height_maps
      grid
        .select { |point, char| char == "a" }
        .map { |st, _| HeightMap.new({**grid, start => "a"}, st) }
    end

    class HeightMap
      HEIGHT_LOOKUP = ("a".."z").map.with_index.to_h

      def initialize(grid, start)
        @grid = grid
        @start = start
      end

      def goal
        @goal ||= @grid.find { |point, char| char == "E" }.first
      end

      def height(point)
        return 0 if point == @start
        return 25 if point == goal
        HEIGHT_LOOKUP.dig(@grid[point])
      end

      def neighbors(point)
        Point.neighbors_of(point).select do |neighbor|
          !@grid[neighbor].nil? && height(neighbor) - height(point) < 2
        end
      end

      def distance(point, other)
        Point.distance(point, other)
      end

      def min_path_cost
        AStar.new(@start, goal, graph: self).execute.min_path_cost
      end

      class AStar < AStarGraph
        def heuristic(node)
          1
        end
      end
    end
  end
end
