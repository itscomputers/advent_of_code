require 'advent/day'
require 'util'

module Advent
  class Day03 < Advent::Day
    DAY = "03"

    def self.sanitized_input
      lines = raw_input.split("\n")
      {
        :size => Point.new(lines.first.size, lines.size),
        :trees => Set.new(
          lines.flat_map.with_index do |line, y|
            line.split("").map.with_index do |symbol, x|
              Point.new(x, y) if symbol == "#"
            end
          end.compact
        ),
      }
    end

    def self.options
      {
        :slopes => {
          :part_1 => [[3, 1]],
          :part_2 => [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]],
        },
      }
    end

    def initialize(input, slopes:)
      @size = input[:size]
      @trees = input[:trees]
      @slopes = slopes
    end

    def solve(part:)
      case part
      when 1 then tree_count_product @slopes[:part_1]
      when 2 then tree_count_product @slopes[:part_2]
      end
    end

    def tree_count(slope)
      (@size.y / slope.y).times.count do |idx|
        @trees.include? Point.new((idx * slope.x) % @size.x, idx * slope.y)
      end
    end

    def tree_count_product(slopes)
      slopes.reduce(1) { |acc, array| acc * tree_count(Point.new *array) }
    end
  end
end
