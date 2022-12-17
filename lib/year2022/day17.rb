require "grid"
require "set"
require "solver"
require "vector"

module Year2022
  class Day17 < Solver
    def solve(part:)
      tetris.handle_pieces(count: piece_count(part: part)).height
    end

    def piece_count(part:)
      case part
      when 1 then 2022
      when 2 then 1000000000000
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

    class Tetris
      def initialize(shapes, gusts, debug: false)
        @shapes = shapes
        @gusts = gusts
        @debug = debug

        @piece_count = 0
        @heights = 7.times.map { [0] }
        @piece = nil
        @stationary = true
        @falling = false
        @gust = nil
      end

      def inspect
        "<Tetris pieces=#{@piece_count}, heights=#{@heights}, stationary=#{@stationary}>"
      end
      alias_method :to_s, :inspect

      def display
        return self if @piece.nil? || !@debug
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

      def height
        @heights.map(&:min).min.abs
      end

      def add_heights(piece)
        piece.border.each do |(x, y)|
          @heights[x] = [*@heights[x], y].min(4)
        end
      end

      def points
        (0..6).flat_map { |x| @heights[x].map { |y| [x, y] } }
      end

      def point?(point)
        @heights[point.first].include?(point.last)
      end

      def handle_pieces(count:)
        handle_piece until @piece_count == count
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

        def border
          (0..6).map do |x|
            @points.select { |point| point.first == x }.min_by(&:last)
          end.compact
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
