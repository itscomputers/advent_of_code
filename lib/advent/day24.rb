require 'advent/day'

module Advent
  class Day24 < Advent::Day
    DAY = "24"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then tile_floor.black_tile_count
      when 2 then tile_floor.flip_tiles_every_day_for(100).black_tile_count
      end
    end

    def tile_floor
      @tile_floor ||= TileFloor.new(@input)
    end

    class TileFloor
      def initialize(tile_strings)
        @black_tiles = tile_strings.each_with_object(Set.new) do |string, set|
          location = location_from string
          set.add?(location) || set.delete(location)
        end
      end

      def black_tile_count
        @black_tiles.size
      end

      def is_black?(location)
        @black_tiles.include? location
      end

      def should_flip?(location)
        count = HexGrid.neighbors_of(location).count(&method(:is_black?))
        if is_black? location
          count == 0 || count > 2
        else
          count == 2
        end
      end

      def black_tiles_to_flip
        @black_tiles.select(&method(:should_flip?))
      end

      def white_tiles_to_flip
        @black_tiles.each_with_object(Hash.new) do |black_tile, memo|
          HexGrid.neighbors_of(black_tile).reject(&method(:is_black?)).each do |white_tile|
            memo[white_tile] ||= { :should_flip => should_flip?(white_tile) }
          end
        end.select { |k, v| v[:should_flip] }.keys
      end

      def flip_tiles!
        new_black = white_tiles_to_flip
        no_longer_black = black_tiles_to_flip
        @black_tiles = @black_tiles + new_black - no_longer_black
        self
      end

      def flip_tiles_every_day_for(days)
        days.times { flip_tiles! }
        self
      end

      def location_from(string)
        location = [0, 0]
        chars = string.chars
        until chars.empty?
          direction = chars.shift
          if ["n", "s"].include? direction
            direction = [direction, chars.shift].join("")
          end
          location = HexGrid.add location, HexGrid.point(direction)
        end
        location
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

