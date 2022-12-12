require "a_star"
require "graph"
require "grid"
require "point"
require "solver"

module Year2022
  class Day12 < Solver
    def solve(part:)
      case part
      when 1 then HeightMap.new(grid).min_path_cost
      when 2 then ReverseHeightMap.new(grid).min_path_cost
      end
    end

    def grid
      @grid ||= Grid.parse(lines, :as => :hash)
    end

    class HeightMap
      HEIGHT_LOOKUP = ("a".."z").map.with_index.to_h

      def initialize(grid)
        @grid = grid
      end

      def start
        @start ||= @grid.find { |point, char| char == "S" }.first
      end

      def goal
        @goal ||= @grid.find { |point, char| char == "E" }.first
      end

      def char(point)
        @grid[point]
      end

      def height(point)
        return 0 if point == start
        return 25 if point == goal
        HEIGHT_LOOKUP.dig(char(point))
      end

      def neighbors(point)
        Point.neighbors_of(point).select do |neighbor|
          !@grid[neighbor].nil? && can_move?(point, neighbor)
        end
      end

      def can_move?(point, neighbor)
        height(neighbor) - height(point) < 2
      end

      def distance(point, other)
        Point.distance(point, other)
      end

      def a_star
        AStarGraph.new(start, goal, graph: self)
      end

      def min_path_cost
        a_star.execute.min_path_cost
      end
    end

    class ReverseHeightMap < HeightMap
      def can_move?(point, neighbor)
        - height(neighbor) + height(point) < 2
      end

      def a_star
        AStar.new(goal, nil, graph: self)
      end

      class AStar < AStarGraph
        def finished?
          @graph.char(@path_node.node) == "a"
        end
      end
    end
  end
end
