require "solver"
require "grid"
require "a_star"
require "point"

module Year2021
  class Day15 < Solver
    def solve(part:)
      cavern_graph(part: part).a_star.execute.min_path_cost
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) { |_, ch| ch.to_i }
    end

    def cavern_graph(part:)
      CavernGraph.new(grid, part: part, size: lines.size)
    end

    class CavernGraph
      def initialize(grid, part:, size:)
        @grid = grid
        @part = part
        @size = size
        @multiplier = part == 1 ? 1 : 5
        @grid = enlarged_grid if part == 2
      end

      def neighbors(node)
        Point.neighbors_of(node).select { |neighbor| @grid.key?(neighbor) }
      end

      def distance(node, neighbor)
        @grid[neighbor]
      end

      def shortest_distance(node)
        neighbors(node).map { |neighbor| distance(node, neighbor) }.min
      end

      def enlarged_grid
        (@multiplier * @multiplier).times.reduce(Hash.new) do |hash, index|
          index_x, index_y = index.divmod(@multiplier)
          @grid.each do |(x, y), value|
            point = [
              x + index_x * @size,
              y + index_y * @size,
            ]
            value = 1 + (value + index_x + index_y - 1) % 9
            hash[point] = value
          end
          hash
        end
      end

      def end_goal
        2.times.map { @multiplier * @size - 1 }
      end

      def a_star
        AStarGraph.new([0, 0], end_goal, graph: self)
      end
    end
  end
end
