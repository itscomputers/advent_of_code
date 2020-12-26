require 'solver'
require 'vector'

module Year2020
  class Day24 < Solver
    def part_one
      tile_floor.active.size
    end

    def part_two
      tile_floor.after(generations: 100).active.size
    end

    def tile_floor
      @tile_floor ||= TileFloor.new.activate!(*initial_points)
    end

    def initial_points
      lines.each_with_object(Set.new) do |string, set|
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
        point = Vector.add point, HexGrid.point(direction)
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

      def self.neighbors_of(point)
        directions.values.map { |direction| Vector.add point, direction }
      end

      def self.point(direction)
        directions[direction]
      end
    end
  end
end

