require "solver"
require "grid"
require "point"
require "vector"
require "algorithms/djikstra"

module Year2021
  class Day15 < Solver
    def solve(part:)
      Algorithms::Djikstra.get_distance(graph(part), [0, 0], target(part))
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) { |_, ch| ch.to_i }
    end

    def graph(part)
      part == 1 ?
        CavernGraph.new(grid) :
        EnlargedCavernGraph.new(grid, size: lines.size, multiplier: multiplier(part))
    end

    def multiplier(part)
      part == 1 ? 1 : 5
    end

    def target(part)
      2.times.map { multiplier(part) * lines.size - 1 }
    end

    class CavernGraph
      def initialize(grid, **_options)
        @grid = grid
      end

      def neighbors(node)
        Point.neighbors_of(node).select { |neighbor| @grid.key?(neighbor) }
      end

      def distance(_node, neighbor)
        @grid[neighbor]
      end
    end

    class EnlargedCavernGraph < CavernGraph
      def initialize(grid, multiplier:, size:)
        @multiplier = multiplier
        @size = size
        @grid = enlarge(grid)
      end

      private

      def enlarge(grid)
        (@multiplier ** 2).times.reduce(Hash.new) do |hash, index|
          tile = index.divmod(5)
          grid.each do |point, value|
            point = Vector.add(point, Vector.scale(tile, @size))
            hash[point] = 1 + (value + tile.sum - 1) % 9
          end
          hash
        end
      end
    end
  end
end
