require "solver"
require "point"
require "algorithms/bfs"

module Year2023
  class Day21 < Solver
    def solve(part:)
      case part
      when 1 then bfs.reachable_count
      when 2 then expanded_bfs.reachable_count
      else nil
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash)
    end

    def graph
      @graph ||= Graph.new(grid)
    end

    def bfs
      @bfs ||= BFS.new(graph, source: graph.start_point).search
    end

    def expanded_bfs
      ExpandedBFS.new(bfs)
    end

    class Graph
      def initialize(grid)
        @grid = grid
      end

      def neighbors(point)
        Point.neighbors_of(point).select { |neighbor| @grid[neighbor] == "." }
      end

      def distance(_source, _target)
        1
      end

      def start_point
        @grid.find { |_point, ch| ch == "S" }.first
      end
    end

    class BFS < Algorithms::BFS
      def reachable_count
        distances.count do |_, distance|
          distance <= step_count && distance % 2 == step_count % 2
        end
      end

      def step_count
        64
      end
    end

    class ExpandedBFS
      def initialize(bfs)
        @bfs = bfs
        @step_count = 26501365
        @tile_count = (@step_count - 65) / 131
      end

      def odd_distances
        @odd_distances ||= @bfs.distances.select { |_, distance| distance % 2 == 1 }
      end

      def even_distances
        @even_distances ||= @bfs.distances.select { |_, distance| distance % 2 == 0 }
      end

      def odd_count
        (@tile_count + 1) ** 2 * odd_distances.size
      end

      def even_count
        @tile_count ** 2 * even_distances.size
      end

      def odd_over_count
        (@tile_count + 1) * odd_distances.count { |_, d| d > 65 }
      end

      def even_under_count
        @tile_count * even_distances.count { |_, d| d > 65 }
      end

      def reachable_count
        odd_count + even_count - odd_over_count + even_under_count
      end
    end
  end
end
