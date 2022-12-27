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
      case part
      when 1 then Path.new(start, grid, movements)
      when 2 then CubePath.new(start, grid, movements)
      end
    end

    def cube_face_size
      50
    end

    def cube_face_mapping
      {
        [0, 2] => [[0, -2], 2],
        [0, 3] => [[1, 0], 3],
      }
    end

    def cube_grid
      CubeGrid.build(grid, cube_face_mapping, cube_face_size)
    end

    class Path
      def initialize(start, grid, movements)
        @position = start
        @grid = grid
        @movements = movements
        @direction = [1, 0]
      end

      def move_forward
        @position = line_of_sight
          .take(@movement + 1)
          .last
      end

      def turn
        @direction = Point.rotate(@direction, @movement == "R" ? :cw : :ccw)
      end

      def move_next
        @movement = @movements.shift
        @movement.is_a?(Integer) ? move_forward : turn
        self
      end

      def move_all
        move_next until @movements.empty?
        self
      end

      def direction_int
        [[1, 0], [0, 1], [-1, 0], [0, -1]].index(@direction)
      end

      def direction_str
        [">", "v", "<", "^"][direction_int]
      end

      def password
        Vector.dot(
          [*@position.map { |coord| coord + 1 }, direction_int],
          [4, 1000, 1],
        )
      end

      def file(position: @position, direction: @direction)
        @grid.keys.select do |point|
          case direction.first.abs
          when 0 then point.first == position.first
          when 1 then point.last == position.last
          end
        end
      end

      def line_of_sight
        (@direction.sum == 1 ? file : file.reverse)
          .cycle(2)
          .drop_while { |point| point != @position }
          .take_while { |point| @grid[point] == "." }
      end
    end

    class CubeGrid
      attr_reader :grid

      def self.build(grid, face_mapping, face_size)
        Builder.new(grid, face_mapping, face_size).build
      end

      def initialize(grid)
        @grid = grid
      end

      def display
        Grid.display(@grid, type: :hash)
      end

      class Builder
        def initialize(grid, face_mapping, face_size)
          @grid = grid
          @face_mapping = face_mapping
          @face_size = face_size
        end

        def build
          grid = @grid.dup
          @face_mapping.each do |orig_pos, (translate, rotate)|
            center = Vector.add(Vector.scale(orig_pos, @face_size), [@face_size / 2 - 0.5, @face_size / 2 - 0.5])
            (0...@face_size).to_a.product((0...@face_size).to_a).each do |point|
              grid_point = Vector.add(point, Vector.scale(orig_pos, @face_size))
              grid_value = grid.delete(grid_point)
              rotate.times {
                grid_point = Point.rotate(grid_point, :cw, center: center).map(&:to_i)
              }
              grid_point = Vector.add(grid_point, Vector.scale(translate, @face_size))
              grid[grid_point] = grid_value
            end
          end
          CubeGrid.new(grid)
        end
      end
    end

    class CubePath < Path
      def move_forward
        super
        # adjust direction
      end

      def line_of_sight
        super # do this for real
      end
    end
  end
end
