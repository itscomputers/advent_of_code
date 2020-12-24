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
        @tiles = tile_strings.map { |string| Tile.new string }
        @black_tiles = initial_state
      end

      def initial_state
        @tiles.each_with_object(Set.new) do |tile, set|
          set.add?(tile.location) || set.delete(tile.location)
        end
      end

      def black_tile_count
        @black_tiles.size
      end

      def tiles_to_flip
        boundary = Set.new
        result = { :black => [], :white => [] }
        @black_tiles.each do |tile|
          black_neighbors, white_neighbors = HexGrid.neighbors_of(tile).partition do |neighbor|
            @black_tiles.include? neighbor
          end
          if black_neighbors.size == 0 || black_neighbors.size > 2
            result[:white] << tile
          end
          boundary += white_neighbors
        end
        boundary.each do |white_tile|
          if (@black_tiles & HexGrid.neighbors_of(white_tile)).size == 2
            result[:black] << white_tile
          end
        end
        result
      end

      def flip_tiles!
        new_black, new_white = tiles_to_flip.slice(:black, :white).values
        @black_tiles = @black_tiles + new_black - new_white
        self
      end

      def flip_tiles_every_day_for(days)
        days.times { flip_tiles! }
        self
      end

      class Tile
        def initialize(string)
          @string = string
        end

        def directions
          result = []
          chars = @string.chars
          until chars.empty?
            char = chars.shift
            if ["n", "s"].include? char
              result << "#{char}#{chars.shift}"
            else
              result << char
            end
          end
          result
        end

        def location
          @location ||= directions.reduce([0, 0]) do |point, direction|
            HexGrid.add point, HexGrid.point(direction)
          end
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

