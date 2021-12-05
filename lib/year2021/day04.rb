require "solver"

module Year2021
  class Day04 < Solver
    def solve(part:)
      case part
      when 1 then Bingo.new(numbers, boards).play_first.winning_score
      when 2 then Bingo.new(numbers, boards).play_last.winning_score
      end
    end

    def numbers
      @numbers ||= lines.first.split(",")
    end

    def boards
      @boards ||= lines.drop(1).each_slice(6).map { |slice| Board.new(slice.drop(1)) }
    end

    class Bingo
      attr_reader :numbers, :boards

      def initialize(numbers, boards)
        @numbers = numbers
        @boards = boards
      end

      def inspect
        "<Bingo boards: #{@boards.map { |board| [*board.rows.map(&:size), *board.cols.map(&:size)].max }.join(", ") }>"
      end

      def play_turn
        number = @numbers.shift
        @boards.each do |board|
          board.call(number)
        end
      end

      def play_first
        play_turn until @boards.any?(&:complete?)
        @winning_board = @boards.select(&:complete?).first
        self
      end

      def play_last
        play_first
        play_turn until @boards.reject(&:complete?).size == 1
        @winning_board = @boards.reject(&:complete?).first
        play_turn until @winning_board.complete?
        self
      end

      def winning_score
        @winning_board.score
      end
    end

    class Board
      attr_reader :rows, :cols

      def initialize(lines)
        @values = lines.flat_map { |line| line.gsub("  ", " ").split(" ") }
        @rows = [[], [], [], [], []]
        @cols = [[], [], [], [], []]
      end

      def inspect
        @values.each_slice(5).map { |row| row.join(" ") }.join("\n")
      end

      def call(number)
        return if complete?

        index = @values.index(number)
        return if index.nil?

        row, col = index.divmod(5)
        @rows[row] << number
        @cols[col] << number
        @values[index] = nil
      end

      def complete?
        @complete ||= ([*@rows, *@cols].map(&:size).max == 5)
      end

      def score
        @values.compact.map(&:to_i).sum * [*@rows, *@cols].max_by(&:size).last.to_i
      end
    end
  end
end
