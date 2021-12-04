require "solver"

module Year2021
  class Day04 < Solver
    def solve(part:)
      case part
      when 1 then play_all
      end
    end

    def numbers
      @numbers ||= lines.first
    end

    def boards
      @boards ||= lines.drop(1).each_slice(6).map { |slice| Board.new(slice.drop(1)) }
    end

    def play_all
      index = 0
      while boards.none?(:complete?)
        boards.each { |board| board.call(numbers[index]) }
      end
      board.select(&:complete?).first.score
    end

    class Board
      def initialize(lines)
        @values = lines.flat_map { |line| line.replace("  ", " ").split(" ") }
        @rows = [[], [], [], [], []]
        @cols = [[], [], [], [], []]
      end

      def call(number)
        row, col = @values.index(number).divmod(5)
        @rows[row] << number
        @cols[col] << number
        @values[index] = nil
      end

      def complete?
        [*@rows, *@cols].map(&:size).max == 5
      end

      def score
        @values.compact.sum * [*@row, *@cols].max_by(&:count).last
      end
    end
  end
end
