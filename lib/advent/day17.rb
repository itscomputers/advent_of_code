require 'advent/day'
require 'game_of_life'

module Advent
  class Day17 < Advent::Day
    DAY = "17"

    def self.sanitized_input
      raw_input.split("\n").map(&:chars)
    end

    def initialize(input)
      @char_array = input
    end

    def solve(part:)
      grid(part + 2).after(generations: 6).active.size
    end

    def grid(dimensions)
      Grid.new(dimensions: dimensions).activate!(*initial_points(dimensions))
    end

    def initial_points(dimensions)
      @char_array.each_with_index.reduce(Set.new) do |set, (row, y)|
        row.map.with_index do |char, x|
          next unless char == "#"
          set.add [x, y, *(dimensions - 2).times.map { 0 }]
        end
        set
      end
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

