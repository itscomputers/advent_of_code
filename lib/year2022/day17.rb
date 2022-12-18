require "grid"
require "set"
require "solver"
require "vector"

module Year2022
  class Day17 < Solver
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
      Tetris.new(shapes, gusts)
    end

    def offset
      38 * 5
    end

    def period
      345 * 5
    end

    def height_after(count:)
      HeightCalculator.new(tetris, offset, period, count).height
    end

    class HeightCalculator
      def initialize(tetris, offset, period, count)
        @tetris = tetris
        @offset = offset
        @period = period
        @count = count
      end

      def heights
        @heights ||= (0..@offset + @period).map do
          @tetris.handle_piece.height
        end
      end

      def divmod
        @divmod ||= (@count - @offset).divmod(@period)
      end

      def quotient
        divmod.first
      end

      def remainder
        divmod.last
      end

      def height
        puts "height at #{@offset}: #{heights[@offset]}"
        puts "height at #{@offset + remainder}: #{heights[@offset + remainder]}"
        puts "height at #{@offset + @period}: #{heights[@offset + @period]}"
        quotient * (heights[@offset + @period] - heights[@offset]) + heights[@offset + remainder]
      end
    end

    class Tetris
      attr_reader :piece_count

      def initialize(shapes, gusts, window_size: nil, debug: false)
        @shapes = shapes
        @gusts = gusts
        @window_size = window_size
        @debug = debug

        @piece_count = 0
        @points_by_y_value = {0 => (0..6).to_a}

        @piece_loc = nil
        @piece = nil
        @movements_by_shape = Hash.new

        @stationary = true
        @falling = false
        @gust = nil
        @lower = 0
      end

      def inspect
        "<Tetris pieces=#{@piece_count}, height=#{height}, stationary=#{@stationary}>"
      end
      alias_method :to_s, :inspect

      def display
        return self if @piece.nil? || !@debug
        puts Grid.display(
          {
            **([-height, @piece.y_min].min - 2..@lower).flat_map { |y_value| [[[-1, y_value], "|"], [[7, y_value], "|"]] }.to_h,
            **(-1..7).map { |x_value| [[x_value, @lower], "-"] }.to_h,
            **points.map { |point| [point, "#"] }.to_h,
            **@piece.points.map { |point| [point, "@"] }.to_h,
            [3, @lower + 1] => @gust || (@falling ? "v" : "-"),
          },
          type: :hash,
        )
        self
      end

      def movements
        @movements_by_shape
      end

      def y_range
        @points_by_y_value.keys.minmax
      end

      def height
        signed_height.abs
      end

      def signed_height
        @points_by_y_value.keys.min
      end

      def add_heights(piece)
        piece.points.each do |(x, y)|
          @points_by_y_value[y] ||= []
          @points_by_y_value[y] << x
        end
        reduce!
      end

      def reduce!
        return if @window_size.nil?
        return unless signed_height + @window_size < @lower
        @lower = signed_height + @window_size
        @points_by_y_value.keys.each do |y|
          @points_by_y_value.delete(y) if y > @lower
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
        until @piece_count == count
          handle_piece
          puts "height at piece ##{@piece_count}: #{height}" if @piece_count % 100 == 0
        end
        self
      end

      def handle_piece
        move_piece until @stationary
        move_piece.display
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
          @piece_loc = piece.loc
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
          @movements_by_shape[@piece.shape] ||= []
          @movements_by_shape[@piece.shape] << Vector.subtract(@piece.loc, @piece_loc)
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
        attr_reader :points, :shape

        def initialize(points)
          @points = points
          @shape = points.hash
        end

        def loc
          [x_min, y_min]
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
