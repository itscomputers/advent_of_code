require "set"
require "solver"
require "point"

module Year2021
  class Day09 < Solver
    def solve(part:)
      case part
      when 1 then low_points.sum(&method(:risk_level))
      when 2 then basins.sort_by(&:size).last(3).map(&:size).reduce(:*)
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) { |(x, y), ch| ch.to_i }
    end

    def low_point?(point)
      Point.neighbors_of(point, strict: true).all? { |neighbor| !grid.key?(neighbor) || grid[neighbor] > grid[point] }
    end

    def risk_level(point)
      grid[point] + 1
    end

    def low_points
      @low_points ||= grid.keys.select(&method(:low_point?))
    end

    def basins
      @basins ||= low_points.map { |point| Basin.new(point, grid) }
    end

    class Basin
      def initialize(point, grid)
        @current = point
        @grid = grid
        @frontier = []
        @visited = Set.new([])
      end

      def size
        advance until @current.nil?
        @visited.size
      end

      def add_to_frontier(neighbor)
        return unless @grid.key?(neighbor)
        return if @grid[neighbor] == 9
        return if @visited.include?(neighbor)
        return if @frontier.include?(neighbor)
        @frontier << neighbor
      end

      def advance
        @visited.add(@current)
        Point.neighbors_of(@current, strict: true).each(&method(:add_to_frontier))
        @current = @frontier.shift
      end
    end
  end
end
