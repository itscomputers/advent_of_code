require "grid"
require "set"
require "solver"
require "vector"

module Year2022
  class Day17 < Solver
    PIECE_COUNT = 4000

    def solve(part:)
      case part
      when 1 then height_after(count: 2022)
      when 2 then height_after(count: 1000000000000)
      end
    end

    def shapes
      [
        [[0, 0], [1, 0], [2, 0], [3, 0]],
        [[1, 0], [0, -1], [1, -1], [2, -1], [1, -2]],
        [[0, 0], [1, 0], [2, 0], [2, -1], [2, -2]],
        [[0, 0], [0, -1], [0, -2], [0, -3]],
        [[0, 0], [0, -1], [1, 0], [1, -1]],
      ].cycle
    end

    def gusts
      lines.first.chars.cycle
    end

    def tetris
      @tetris ||= Tetris.new(shapes, gusts)
    end

    def height_after(count:)
      if count < PIECE_COUNT
        tetris.handle_pieces(count: count).height
      else
        HeightCalculator.new(tetris, count).height
      end
    end

    class HeightCalculator
      def initialize(tetris, count)
        @tetris = tetris
        @count = count

        @max_index = PIECE_COUNT / 8
        compute_offset_and_period

        @quotient, @remainder = divmod
      end

      def compute_offset_and_period
        @max_index.times.each do |offset|
          period = (2..@max_index).find do |index|
            differences(offset).take(index) == differences(offset).drop(index).take(index)
          end
          next if period.nil?
          @offset = offset * 5
          @period = period * 5
          return
        end
      end

      def heights
        @tetris.handle_pieces(count: PIECE_COUNT).heights
      end

      def differences(offset)
        @differences ||= heights.each_cons(2).map { |prev, curr| curr - prev }.each_slice(5).to_a
        @differences.drop(offset)
      end

      def divmod
        (@count - @offset).divmod(@period)
      end

      def height
        @quotient * (heights[@offset + @period] - heights[@offset]) + heights[@offset + @remainder]
      end
    end

    class Tetris
      attr_reader :heights

      def initialize(shapes, gusts)
        @shapes = shapes
        @gusts = gusts

        @piece_count = 0
        @heights = []
        @points_by_y_value = {0 => (0..6).to_a}
        @piece = nil

        @stationary = true
        @falling = false
        @gust = nil
      end

      def inspect
        "<Tetris pieces=#{@piece_count}, height=#{height}, stationary=#{@stationary}>"
      end
      alias_method :to_s, :inspect

      def display
        return self if @piece.nil?
        puts Grid.display(
          {
            **([-height, @piece.y_min].min - 2..0).flat_map { |y_value| [[[-1, y_value], "|"], [[7, y_value], "|"]] }.to_h,
            **(-1..7).map { |x_value| [[x_value, 0], "-"] }.to_h,
            **points.map { |point| [point, "#"] }.to_h,
            **@piece.points.map { |point| [point, "@"] }.to_h,
            [3, 1] => @gust || (@falling ? "v" : "-"),
          },
          type: :hash,
        )
        self
      end

      def y_range
        @points_by_y_value.keys.minmax
      end

      def height
        @points_by_y_value.keys.min.abs
      end

      def add_heights(piece)
        piece.points.each do |(x, y)|
          @points_by_y_value[y] ||= []
          @points_by_y_value[y] << x
        end
      end

      def points
        @points_by_y_value.flat_map { |y, x_values| x_values.map { |x| [x, y] } }
      end

      def point?(point)
        return false unless @points_by_y_value.key?(point.last)
        @points_by_y_value[point.last].include?(point.first)
      end

      def handle_pieces(count:)
        handle_piece.save_height  until @piece_count == count
        self
      end

      def save_height
        @heights << height
      end

      def handle_piece
        move_piece until @stationary
        new_piece
      end

      def move_piece
        if @stationary
          new_piece
        elsif @gust
          handle_gust
        elsif @falling
          handle_falling
        end
      end

      def new_piece
        return unless @stationary
        @piece = Piece.new(@shapes.next).tap do |piece|
          piece.move_by([2, -(height + 4)])
          @stationary = false
          @gust = @gusts.next
        end
        self
      end

      def handle_gust
        return if @gust.nil?
        if @gust == "<"
          @piece.move_by([-1, 0])
          @piece.move_by([1, 0]) if collision?
        elsif @gust == ">"
          @piece.move_by([1, 0])
          @piece.move_by([-1, 0]) if collision?
        end
        @gust = nil
        @falling = true
        self
      end

      def handle_falling
        return unless @falling
        @piece.move_by([0, 1])
        if collision?
          @piece.move_by([0, -1])
          @stationary = true
          @piece_count += 1
          add_heights(@piece)
        else
          @gust = @gusts.next
        end
        @falling = false
        self
      end

      def collision?
        return true if @piece.x_min < 0
        return true if @piece.x_max > 6
        @piece.points.any?(&method(:point?))
      end

      class Piece
        attr_reader :points

        def initialize(points)
          @points = points
        end

        def x_min
          @points.map(&:first).min
        end

        def x_max
          @points.map(&:first).max
        end

        def y_min
          @points.map(&:last).min
        end

        def move_by(direction)
          @points = @points.map { |point| Vector.add(point, direction) }
        end
      end
    end
  end
end
