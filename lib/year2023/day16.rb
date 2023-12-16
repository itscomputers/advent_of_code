require "solver"
require "vector"
require "point"

module Year2023
  class Day16 < Solver
    def solve(part:)
      case part
      when 1 then contraption.energize.count
      when 2 then optimal_contraption.count
      else nil
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash)
    end

    def contraption(location: [0, 0], direction: [1, 0])
      Contraption.new(grid, location, direction)
    end

    def x_range
      @x_range ||= Grid.x_range(grid.keys)
    end

    def y_range
      @y_range ||= Grid.y_range(grid.keys)
    end

    def optimal_contraption
      [
        *x_range.flat_map do |x|
          [
            contraption(location: [x, 0], direction: [0, 1]),
            contraption(location: [x, y_range.max], direction: [0, -1]),
          ]
        end,
        *y_range.flat_map do |y|
          [
            contraption(location: [0, y], direction: [1, 0]),
            contraption(location: [x_range.max, y], direction: [-1, 0]),
          ]
        end,
      ].map(&:energize).max_by(&:count)
    end

    class Contraption
      def initialize(grid, location, direction)
        @grid = grid
        @beams = [Beam.new(location, direction)]
        @energized = Hash.new { |h, k| h[k] = [] }
      end

      def energize
        move_beam until @beams.empty?
        self
      end

      def count
        @energized.size
      end

      def move_beam
        beam = @beams.pop
        ch = @grid[beam.location]

        return if visited?(beam)
        return if ch.nil?

        @energized[beam.location] << beam.char

        if ch == "."
          @beams << beam.move
        elsif beam.horizontal?
          case ch
          when "-" then
            @beams << beam.move
          when "|" then
            @beams << beam.copy.rotate(:cw)
            @beams << beam.rotate(:ccw)
          when "/" then
            @beams << beam.rotate(:ccw)
          else
            @beams << beam.rotate(:cw)
          end
        else
          case ch
          when "-" then
            @beams << beam.copy.rotate(:cw)
            @beams << beam.rotate(:ccw)
          when "|" then
            @beams << beam.move
          when "/" then
            @beams << beam.rotate(:cw)
          else
            @beams << beam.rotate(:ccw)
          end
        end
      end

      def visited?(beam)
        @energized.key?(beam.location) && @energized[beam.location].include?(beam.char)
      end

      class Beam < Struct.new(:location, :direction)
        def move
          self.location = Vector.add(location, direction)
          self
        end

        def char
          case direction
          when [0, 1] then "v"
          when [0, -1] then "^"
          when [1, 0] then ">"
          when [-1, 0] then "<"
          else nil
          end
        end

        def rotate(direction)
          self.direction = Point.rotate(self.direction, direction)
          move
          self
        end

        def copy
          Beam.new(self.location, self.direction)
        end

        def horizontal?
          direction.last == 0
        end
      end
    end
  end
end
