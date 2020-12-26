require 'solver'
require 'game_of_life'
require 'grid_parser'

module Year2020
  class Day17 < Solver
    def solve(part:)
      grid(part + 2).after(generations: 6).active.size
    end

    def grid(dimensions)
      Grid.new(dimensions: dimensions).activate!(*initial_points(dimensions))
    end

    def points
      @initial_points ||= grid_parser.parse_as_set(char: "#")
    end

    def initial_points(dimensions)
      points.map { |point| [*point, *Array.new(dimensions - 2) { 0 }] }
    end

    class Grid < GameOfLife
      def initialize(dimensions:)
        @dimensions = dimensions
        super
      end

      def directions
        @directions ||= (@dimensions - 1).times.reduce([-1, 0, 1]) do |array, _|
          [-1, 0, 1].product(array)
        end.map(&:flatten) - [Array.new(@dimensions) { 0 }]
      end
    end
  end
end

