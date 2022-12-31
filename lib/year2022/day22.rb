require "grid"
require "point"
require "solver"
require "vector"

module Year2022
  class Day22 < Solver
    def solve(part:)
      path(part: part).move_all.password
    end

    def start
      [lines.first.index("."), 0]
    end

    def grid
      @grid ||= Grid.parse(chunks.first.split("\n"), as: :hash).select do |point, char|
        char != " "
      end
    end

    def movements
      movement_pairs = chunks.last.scan(/\d+[LR]/).map do |string|
        *number_chars, direction = string.chars
        [number_chars.join.to_i, direction]
      end
      final_match = chunks.last.match(/\d+$/)
      [
        *movement_pairs.flatten,
        final_match.nil? ? nil : final_match[0].to_i,
      ].compact
    end

    def path(part:)
      Path.new(start, grid, movements, edge_mapping_for(part: part), size)
    end

    def edge_mapping
      {
        [[1, 0], [-1, 0]] => {
          1 => [[2, 0], [-1, 0]],
          2 => [[0, 2], [1, 0]],
        },
        [[1, 0], [0, -1]] => {
          1 => [[1, 2], [0, -1]],
          2 => [[0, 3], [1, 0]],
        },
        [[2, 0], [1, 0]] => {
          1 => [[1, 0], [1, 0]],
          2 => [[1, 2], [-1, 0]],
        },
        [[2, 0], [0, -1]] => {
          1 => [[2, 0], [0, -1]],
          2 => [[0, 3], [0, -1]],
        },
        [[2, 0], [0, 1]] => {
          1 => [[2, 0], [0, 1]],
          2 => [[1, 1], [-1, 0]],
        },
        [[1, 1], [1, 0]] => {
          1 => [[1, 1], [1, 0]],
          2 => [[2, 0], [0, -1]],
        },
        [[1, 1], [-1, 0]] => {
          1 => [[1, 1], [-1, 0]],
          2 => [[0, 2], [0, 1]],
        },
        [[0, 2], [-1, 0]] => {
          1 => [[1, 2], [-1, 0]],
          2 => [[1, 0], [1, 0]],
        },
        [[0, 2], [0, -1]] => {
          1 => [[0, 3], [0, -1]],
          2 => [[1, 1], [1, 0]],
        },
        [[1, 2], [1, 0]] => {
          1 => [[0, 2], [1, 0]],
          2 => [[2, 0], [-1, 0]],
        },
        [[1, 2], [0, 1]] => {
          1 => [[1, 0], [0, 1]],
          2 => [[0, 3], [-1, 0]],
        },
        [[0, 3], [-1, 0]] => {
          1 => [[0, 3], [-1, 0]],
          2 => [[1, 0], [0, 1]],
        },
        [[0, 3], [0, 1]] => {
          1 => [[0, 2], [0, 1]],
          2 => [[2, 0], [0, 1]],
        },
        [[0, 3], [1, 0]] => {
          1 => [[0, 3], [1, 0]],
          2 => [[1, 2], [0, -1]],
        },
      }
    end

    def edge_mapping_for(part:)
      edge_mapping.map { |key, value| [key, value[part]] }.to_h
    end

    def size
      50
    end

    class Path
      def initialize(start, grid, movements, mapping, size)
        @mapping = mapping
        @size = size
        @grid = grid
        @movements = movements
        @directed_point = DirectedPoint.new(start, [1, 0])
      end

      def move_all
        move_next until @movements.empty?
        self
      end

      def password
        Vector.dot(
          [*@directed_point.point.map { |coord| coord + 1 }, direction_int],
          [4, 1000, 1],
        )
      end

      def move_next
        @movement = @movements.shift
        return self if @movement.nil?
        @movement.is_a?(Integer) ? move_forward : turn
        self
      end

      def move_forward
        @directed_point = directed_line_of_sight.last
      end

      def turn
        @directed_point.direction = Point.rotate(
          @directed_point.direction,
          @movement == "R" ? :cw : :ccw,
        )
      end

      def direction_int
        [[1, 0], [0, 1], [-1, 0], [0, -1]].index(@directed_point.direction)
      end

      def direction_str
        [">", "v", "<", "^"][direction_int]
      end

      def directed_line_of_sight
        @movement.times.reduce([@directed_point]) do |array, _|
          directed_point = next_directed_point(array.last)
          raise "off grid #{array.last} ~> #{directed_point}" if @grid[directed_point.point].nil?
          @grid[directed_point.point] == "." ?
            [*array, directed_point] :
            array
        end
      end

      def next_directed_point(directed_point)
        NextPointBuilder.new(directed_point, @mapping, @size).build
      end

      class NextPointBuilder
        def initialize(directed_point, mapping, size)
          @directed_point = directed_point
          @full_mapping = mapping
          @size = size
        end

        def zone
          @zone ||= Zone.new(
            @directed_point.point.map { |coord| coord / @size },
            @size,
          )
        end

        def mapping
          @full_mapping[[zone.position, direction]]
        end

        def point
          @directed_point.point
        end

        def rel_x
          point.first % @size
        end

        def rel_y
          point.last % @size
        end

        def direction
          @directed_point.direction
        end

        def next_zone
          @next_zone ||= mapping.nil? ?
            nil :
            Zone.new(mapping.first, @size)
        end

        def next_direction
          mapping&.last
        end

        def use_default?
          return true if mapping.nil?
          case direction
          when [1, 0] then point.first != zone.right
          when [-1, 0] then point.first != zone.left
          when [0, 1] then point.last != zone.bottom
          when [0, -1] then point.last != zone.top
          end
        end

        def next_point
          case [direction, next_direction]
          when [[1, 0], [1, 0]] then [next_zone.left, next_zone.top + rel_y]
          when [[1, 0], [-1, 0]] then [next_zone.right, next_zone.bottom - rel_y]
          when [[1, 0], [0, 1]] then [next_zone.right - rel_y, next_zone.top]
          when [[1, 0], [0, -1]] then [next_zone.left + rel_y, next_zone.bottom]

          when [[-1, 0], [1, 0]] then [next_zone.left, next_zone.bottom - rel_y]
          when [[-1, 0], [-1, 0]] then [next_zone.right, next_zone.top + rel_y]
          when [[-1, 0], [0, 1]] then [next_zone.left + rel_y, next_zone.top]
          when [[-1, 0], [0, -1]] then [next_zone.right - rel_y, next_zone.bottom]

          when [[0, 1], [1, 0]] then [next_zone.left, next_zone.bottom - rel_x]
          when [[0, 1], [-1, 0]] then [next_zone.right, next_zone.top + rel_x]
          when [[0, 1], [0, 1]] then [next_zone.left + rel_x, next_zone.top]
          when [[0, 1], [0, -1]] then [next_zone.right - rel_x, next_zone.bottom]

          when [[0, -1], [1, 0]] then [next_zone.left, next_zone.top + rel_x]
          when [[0, -1], [-1, 0]] then [next_zone.right, next_zone.bottom - rel_x]
          when [[0, -1], [0, -1]] then [next_zone.left + rel_x, next_zone.bottom]
          when [[0, -1], [0, 1]] then [next_zone.right - rel_x, next_zone.top]
          end
        end

        def build
          return @directed_point.default_next if use_default?
          DirectedPoint.new(next_point, next_direction)
        end

        class Zone < Struct.new(:position, :size)
          def top
            position.last * size
          end

          def bottom
            (position.last + 1) * size - 1
          end

          def left
            position.first * size
          end

          def right
            (position.first + 1) * size - 1
          end
        end
      end

      class DirectedPoint < Struct.new(:point, :direction)
        def default_next
          DirectedPoint.new(Vector.add(point, direction), direction)
        end
      end
    end
  end
end
