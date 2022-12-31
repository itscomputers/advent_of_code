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
        [[1, 2], [-1, 0]] => {
          1 => [[1, 2], [-1, 0]],
          2 => [[0, 2], [0, 1]],
        },
        [[1, 2], [1, 0]] => {
          1 => [[1, 2], [1, 0]],
          2 => [[2, 0], [0, -1]],
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
          2 => [[2, 0], [-1, 0]],
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
        @path = Hash.new
      end

      def inspect
        "<Path pos=#{@position} dir=#{@direction} move=#{movement}>"
      end

      def display
        puts "\n------------\n#{Grid.display({**@grid, **@path}, type: :hash)}\n------------\n"
      end

      def movement
        @movement ||= @movements.shift
      end

      def move_forward
        @directed_point = directed_line_of_sight.last
        @movement = nil
      end

      def turn
        @directed_point.direction = Point.rotate(
          @directed_point.direction,
          movement == "R" ? :cw : :ccw,
        )
        @movement = nil
      end

      def move_next
        return self if movement.nil?
        movement.is_a?(Integer) ? move_forward : turn
        @path[@directed_point.point] = direction_str
        self
      end

      def move_all
        move_next until @movements.empty?
#       display
        puts "point: #{@directed_point.point}"
        puts "direction: #{@directed_point.direction}"
        self
      end

      def direction_int
        [[1, 0], [0, 1], [-1, 0], [0, -1]].index(@directed_point.direction)
      end

      def direction_str
        [">", "v", "<", "^"][direction_int]
      end

      def password
        Vector.dot(
          [*@directed_point.point.map { |coord| coord + 1 }, direction_int],
          [4, 1000, 1],
        )
      end

      def directed_line_of_sight
        movement.times.reduce([@directed_point]) do |array, _|
          directed_point = next_directed_point(array.last)
          return array if @grid[directed_point.point] == "#"
          @path[directed_point.point] = {
            [1, 0] => ">",
            [-1, 0] => "<",
            [0, 1] => "v",
            [0, -1] => "^",
          }[directed_point.direction]
          [*array, directed_point]
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
          when [[1, 0], [1, 0]] then [next_zone.left, point.last]
          when [[1, 0], [-1, 0]] then [next_zone.right, next_zone.bottom - rel_y]
          when [[1, 0], [0, 1]] then [next_zone.right - rel_y, next_zone.top]
          when [[1, 0], [0, -1]] then [next_zone.right - rel_y, next_zone.bottom]

          when [[-1, 0], [1, 0]] then [next_zone.left, next_zone.bottom - rel_y]
          when [[-1, 0], [-1, 0]] then [next_zone.right, point.last]
          when [[-1, 0], [0, 1]] then [next_zone.right - rel_y, next_zone.top]
          when [[-1, 0], [0, -1]] then [next_zone.right - rel_y, next_zone.bottom]

          when [[0, 1], [1, 0]] then [next_zone.left, next_zone.bottom - rel_x]
          when [[0, 1], [-1, 0]] then [next_zone.right, next_zone.bottom - rel_x]
          when [[0, 1], [0, 1]] then [point.first, next_zone.top]
          when [[0, 1], [0, -1]] then [next_zone.right - rel_x, next_zone.bottom]

          when [[0, -1], [1, 0]] then [next_zone.left, next_zone.bottom - rel_x]
          when [[0, -1], [-1, 0]] then [next_zone.right, next_zone.bottom - rel_x]
          when [[0, -1], [0, -1]] then [point.first, next_zone.bottom]
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
