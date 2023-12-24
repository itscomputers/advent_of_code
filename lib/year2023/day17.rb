require "solver"
require "point"
require "vector"
require "algorithms/djikstra"

module Year2023
  class Day17 < Solver
    def solve(part:)
      case part
      when 1 then djikstra.search.get_distance
      when 2 then ultra_djikstra.search.get_distance
      else nil
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) { |_, ch| ch.to_i }
    end

    def target
      Grid.dimensions(grid.keys).map { |val| val - 1 }
    end

    def djikstra
      graph = Graph.new(grid)
      Djikstra.new(graph, source: graph.source, target: target)
    end

    def ultra_djikstra
      graph = UltraGraph.new(grid)
      UltraDjikstra.new(graph, source: graph.source, target: target)
    end

    class Graph
      Vertex = Struct.new(:point, :direction, :dir_count)
      DIRECTIONS = [[1, 0], [0, 1], [-1, 0], [0, -1]]

      def initialize(grid)
        @grid = grid
      end

      def source
        Vertex.new([0, 0], [0, 0], 0)
      end

      def neighbors(vertex)
        DIRECTIONS.map { |direction| build_neighbor(vertex, direction) }.compact
      end

      def distance(_source, target)
        @grid[target.point]
      end

      def invalid_point?(vertex, direction)
        @grid[Vector.add(vertex.point, direction)].nil?
      end

      def opposite_direction?(vertex, direction)
        direction == Vector.scale(vertex.direction, -1)
      end

      def invalid_continuation?(vertex, direction)
        dir_count(vertex, direction) > 2
      end

      def dir_count(vertex, direction)
        direction == vertex.direction ? vertex.dir_count + 1 : 0
      end

      def build_neighbor(vertex, direction)
        return if invalid_point?(vertex, direction)
        return if opposite_direction?(vertex, direction)
        return if invalid_continuation?(vertex, direction)
        Vertex.new(
          Vector.add(vertex.point, direction),
          direction,
          dir_count(vertex, direction),
        )
      end
    end

    class UltraGraph < Graph
      def invalid_continuation?(vertex, direction)
        return false if vertex.direction == [0, 0]
        if vertex.direction == direction
          dir_count(vertex, direction) > 9
        else
          vertex.dir_count < 3
        end
      end
    end

    class Djikstra < Algorithms::Djikstra
      def finished?(node, target: @target)
        if target == node.key.point
          @target = node.key
          return true
        end
        false
      end
    end

    class UltraDjikstra < Algorithms::Djikstra
      def finished?(node, target: @target)
        if target == node.key.point && node.key.dir_count > 3
          @target = node.key
          return true
        end
        false
      end
    end
  end
end
