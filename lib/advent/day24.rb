require 'advent/day'

module Advent
  class Day24 < Advent::Day
    DAY = "24"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def initialize(input)
      @tile_strings = input
    end

    def solve(part:)
      case part
      when 1 then tile_floor.active.size
      when 2 then tile_floor.after(generations: 100).active.size
      end
    end

    def tile_floor
      @tile_floor ||= TileFloor.new.activate!(*initial_points)
    end

    def initial_points
      @tile_strings.each_with_object(Set.new) do |string, set|
        point = point_from string
        set.add?(point) || set.delete(point)
      end
    end

    def point_from(string)
      point = [0, 0]
      chars = string.chars
      until chars.empty?
        direction = chars.shift
        if ["n", "s"].include? direction
          direction = [direction, chars.shift].join("")
        end
        point = HexGrid.add point, HexGrid.point(direction)
      end
      point
    end

    class TileFloor < GameOfLife
      def directions
        @directions ||= HexGrid.directions.values
      end

      def condition_for(action)
        case action
        when :activating then lambda { |count| count == 2 }
        when :deactivating then lambda { |count| count == 0 || count > 2 }
        end
      end
    end

    class HexGrid
      def self.directions
        @directions ||= {
          'e' => [1, 0],
          'ne' => [0, 1],
          'nw' => [-1, 1],
          'w' => [-1, 0],
          'sw' => [0, -1],
          'se' => [1, -1],
        }
      end

      def self.add(point, other)
        point.zip(other).map(&:sum)
      end

      def self.neighbors_of(point)
        directions.values.map { |direction| add point, direction }
      end

      def self.point(direction)
        directions[direction]
      end
    end
  end
end

