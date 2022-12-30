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
      when 2 then CubePath.new([cube_face_size, 0], cube_grid, movements)
      end
    end

    def edge_mapping

    end

    def cube_face_size
      @cube_face_size ||= 50
    end

    def cube_face_mapping
      @cube_face_mapping ||= {
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

      def inspect
        "<Path pos=#{@position} dir=#{@direction} move=#{@movement}>"
      end

      def movement
        @movement ||= @movements.shift
      end

      def move_forward
        @position = line_of_sight.take(movement + 1).last
        @movement = nil
      end

      def turn
        @direction = Point.rotate(@direction, movement == "R" ? :cw : :ccw)
        @movement = nil
      end

      def move_next
        return self if movement.nil?
        movement.is_a?(Integer) ? move_forward : turn
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

    class CubePath < Path
      def move_forward
        cube_point = cube_line_of_sight.last
        @position = cube_point.point
        @direction = cube_point.direction
        @movement = nil
      end

      def cube_line_of_sight
        movement.times.reduce([CubePoint.new(@position, @direction, @grid.face_size)]) do |array, _|
          next_cube_point = array.last.next_point
          return array if @grid.grid[next_cube_point.point] == "#"
          [*array, next_cube_point]
        end
      end

      def password
        if @grid.mapping.key?(@position)
          point, rotate = @grid.mapping[@position].values
          @position = point
          rotate.times { @direction = Point.rotate(@direction, :cw) }
        end
        super
      end
    end

    class CubePoint < Struct.new(:point, :direction, :size)
      def next_point
        if direction == [1, 0]
          if point.first == 2 * size - 1
            case point.last / size
            when 1
              return build(
                pt: [point.last + size, point.first - size],
                dir: [0, -1],
              )
            when 2
              return build(
                pt: [point.first + 4, 3 * size - point.last - 1],
                dir: [-1, 0],
              )
            when 3
              return build(
                pt: [6 * size - point.last - 1, 0],
                dir: [0, 1],
              )
            end
          elsif point.first == 3 * size - 1
            if point.last / size == 0
              return build(
                pt: [point.first - size, 3 * size - point.last - 1],
                dir: [-1, 0],
              )
            end
          end
        elsif direction == [0, 1]
          if point.last == size - 1
            case point.first / size
            when 0
              return build(
                pt: [point.last + 1, 2 * size - point.first - 1],
                dir: [1, 0],
              )
            when 2
              return build(
                pt: [point.last + size, point.first - size],
                dir: [-1, 0],
              )
            end
          elsif point.last == 4 * size - 1
            if point.first / size == 1
              return build(
                pt: [point.first, 0],
                dir: [0, 1],
              )
            end
          end
        elsif direction == [0, -1]
          if point.last == 0
            case point.first / size
            when 0
              return build(
                pt: [point.last + size, point.first + 3 * size],
                dir: [1, 0],
              )
            when 1
              return build(
                pt: [point.first, 4 * size - 1],
                dir: [0, -1],
              )
            when 2
              return build(
                pt: [2 * size - 1, 6 * size - point.first - 1],
                dir: [-1, 0],
              )
            end
          end
        elsif direction == [-1, 0]
          if point.first == 0
            if point.last / size == 0
              return build(
                pt: [point.first + size, 3 * size - point.last - 1],
                dir: [1, 0],
              )
            end
          elsif point.first == size
            case point.last / size
            when 1
              return build(
                pt: [2 * size - point.last - 1, point.first - 1],
                dir: [0, -1],
              )
            when 2
              return build(
                pt: [point.first - size, 3 * size - point.last - 1],
                dir: [1, 0],
              )
            when 3
              return build(
                pt: [point.last - 3 * size, point.first - size],
                dir: [0, 1],
              )
            end
          end
        end
        build
      end

      def build(pt: nil, dir: nil)
        CubePoint.new(
          pt || Vector.add(point, direction),
          dir || direction,
          size,
        )
      end
    end

    class CubeGrid
      attr_reader :grid, :face_size, :mapping

      def self.build(grid, face_mapping, face_size)
        Builder.new(grid, face_mapping, face_size).build
      end

      def initialize(grid, face_size, mapping)
        @grid = grid
        @face_size = face_size
        @mapping = mapping
      end

      def display
        Grid.display(@grid, type: :hash)
      end

      class Builder
        def initialize(grid, face_mapping, face_size)
          @grid = grid
          @face_mapping = face_mapping
          @face_size = face_size
          @mapping = Hash.new
        end

        def build
          grid = @grid.dup
          @face_mapping.each do |orig_pos, (translate, rotate)|
            center = Vector.add(Vector.scale(orig_pos, @face_size), [@face_size / 2 - 0.5, @face_size / 2 - 0.5])
            (0...@face_size).to_a.product((0...@face_size).to_a).each do |point|
              orig_point = Vector.add(point, Vector.scale(orig_pos, @face_size))
              grid_value = grid.delete(orig_point)
              grid_point = orig_point.dup
              rotate.times {
                grid_point = Point.rotate(grid_point, :cw, center: center).map(&:to_i)
              }
              grid_point = Vector.add(grid_point, Vector.scale(translate, @face_size))
              grid[grid_point] = grid_value
              @mapping[grid_point] = {
                point: orig_point,
                rotate: rotate,
              }
            end
          end
          CubeGrid.new(grid, @face_size, @mapping)
        end
      end
    end
  end
end
