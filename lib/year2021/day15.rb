require "solver"
require "grid"
require "a_star"
require "point"

module Year2021
  class Day15 < Solver
    def solve(part:)
      case part
      when 1 then a_star.search.minimum_path.drop(1).sum { |path_node| grid[path_node.node] }
      when 2 then enlarged_a_star.search.minimum_path.drop(1).sum { |path_node| enlarged_grid[path_node.node] }
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) { |_, ch| ch.to_i }
    end

    def size
      lines.size
    end

    def cavern_graph
      CavernGraph.new(grid)
    end

    def end_goal
      2.times.map { size - 1 }
    end

    def a_star
      AStar.new(cavern_graph, [0, 0], static_goal: end_goal)
    end

    def multiplier
      5
    end

    def enlarged_grid
      @enlarged_grid ||= (multiplier * multiplier).times.reduce(Hash.new) do |hash, index|
        index_x, index_y = index.divmod(multiplier)
        grid.each do |(x, y), value|
          point = [
            x + index_x * size,
            y + index_y * size,
          ]
          value = 1 + (value + index_x + index_y - 1) % 9
          hash[point] = value
        end
        hash
      end
    end

    def enlarged_cavern_graph
      CavernGraph.new(enlarged_grid)
    end

    def enlarged_end_goal
      2.times.map { multiplier * size - 1 }
    end

    def enlarged_a_star
      AStar.new(enlarged_cavern_graph, [0, 0], static_goal: enlarged_end_goal)
    end

    class CavernGraph
      def initialize(grid)
        @grid = grid
      end

      def neighbors_of(node)
        Point.neighbors_of(node).select { |neighbor| @grid.key?(neighbor) }
      end

      def distance(node, neighbor)
        @grid[neighbor]
      end
    end
  end
end
