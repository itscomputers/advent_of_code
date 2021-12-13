require "solver"
require "grid"

module Year2021
  class Day13 < Solver
    POINT_REGEX = /(\d+),(\d+)/
    FOLD_REGEX = /fold along (x|y)=(\d+)/

    def solve(part:)
      case part
      when 1 then transparent_paper.apply_fold.point_count
      when 2 then "\n#{transparent_paper.apply_folds.display}"
      end
    end

    def transparent_paper
      @transparent_paper ||= TransparentPaper.new(points, folds)
    end

    def points
      lines
        .take_while { |line| POINT_REGEX.match(line) }
        .map(&method(:point_from))
    end

    def folds
      lines
        .drop_while { |line| !FOLD_REGEX.match(line) }
        .map(&method(:fold_from))
    end

    def point_from(line)
      POINT_REGEX.match(line).to_a.drop(1).map(&:to_i)
    end

    def fold_from(line)
      match = FOLD_REGEX.match(line)
      [
        match[1] == "x" ? 0 : 1,
        match[2].to_i,
      ]
    end

    class TransparentPaper
      attr_reader :points

      def initialize(points, folds)
        @points = points
        @folds = folds
      end

      def points_after(fold)
        @points.map { |point| point.fold_at(*fold) }.uniq
      end

      def apply_fold
        @points = points_after(@folds.shift)
        self
      end

      def apply_folds
        apply_fold until @folds.empty?
        self
      end

      def point_count
        @points.size
      end

      def display
        Grid.display(points, :type => :array, "0" => ".", "1" => "#")
      end
    end
  end
end

class Array
  def fold_at(index, center)
    value = at(index)
    return self if value.nil? || value < center
    fill(2 * center - value, index, 1)
  end
end
