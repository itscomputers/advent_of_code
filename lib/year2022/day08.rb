require "grid"
require "solver"

module Year2022
  class Day08 < Solver
    def solve(part:)
      case part
      when 1 then edge_sight_lines.flat_map(&:visible).uniq.size
      when 2 then scenic_scores.max
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash) do |point, char|
        Tree.new(point, char.to_i)
      end
    end

    def edge_sight_lines
      @edge_sight_lines ||= [
        *Grid.x_range(grid.keys).flat_map do |x|
          [false, true].map { |reverse| EdgeSightLine.new(grid, 0, x, reverse) }
        end,
        *Grid.y_range(grid.keys).flat_map do |y|
          [false, true].map { |reverse| EdgeSightLine.new(grid, 1, y, reverse) }
        end,
      ]
    end

    def scenic_scores
      @scenic_scores ||= grid.keys.map { |point| Scenery.new(grid, point).score }
    end

    class Tree < Struct.new(:point, :height)
    end

    class EdgeSightLine
      def initialize(grid, orientation, index, reverse)
        @grid = grid
        @trees = @grid.select { |point, tree| point[orientation] == index }.values
        @trees.reverse! if reverse
      end

      def visible
        return @visible unless @visible.nil?

        @visible = [@trees.shift]
        until @trees.empty?
          tree = @trees.shift
          @visible << tree if visible?(tree)
        end
        @visible
      end

      def visible?(tree)
        tree.height > @visible.last.height
      end
    end

    class TreeSightLine < EdgeSightLine
      def initialize(grid, orientation, point, reverse)
        super(grid, orientation, point[orientation], false)
        if reverse
          @trees = @trees.take(point[1 - orientation] + 1).reverse
        else
          @trees = @trees.drop(point[1 - orientation])
        end
        @tree = @trees.first
      end

      def visible?(tree)
        @visible.size == 1 ||
          @tree.height > @visible.last.height ||
          (
            tree.height >= @tree.height &&
            @visible.last.height < @tree.height
          )
      end

      def visible_count
        visible.size - 1
      end
    end

    class Scenery
      def initialize(grid, point)
        @grid = grid
        @point = point
      end

      def sight_lines
        @sight_lines ||= [0, 1].product([false, true]).map do |orientation, reverse|
          TreeSightLine.new(@grid, orientation, @point, reverse)
        end
      end

      def score
        sight_lines.map(&:visible_count).reduce(&:*)
      end
    end
  end
end
