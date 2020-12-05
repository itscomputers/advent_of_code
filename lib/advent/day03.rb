require 'advent/day'

Point = Struct.new(:x, :y)

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

    def initialize(input)
      @size = input[:size]
      @trees = input[:trees]
    end

    def solve(part:)
      case part
      when 1 then tree_count Point.new(3, 1)
      when 2 then tree_count_product [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]].map { |arr| Point.new(*arr) }
      end
    end

    def max_x
      @max_x ||= @locations.keys.map(&:x).max
    end

    def max_y
      @max_y ||= @locations.keys.map(&:y).max
    end

    def display
      @display ||= @size.y.times.map do |y|
        @size.x.times.map do |x|
          @trees.include?(Point.new(x, y)) ? "#" : "."
        end.join
      end.join("\n")
    end

    def tree_count(slope)
      (0...@size.y).step(slope.y).select.with_index do |y, idx|
        @trees.include? Point.new((idx * slope.x) % @size.x, y)
      end.count
    end

    def tree_count_product(slopes)
      slopes.reduce(1) { |acc, slope| acc * tree_count(slope) }
    end
  end
end
