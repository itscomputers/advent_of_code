require "solver"

module Year2021
  class Day04 < Solver
    def solve(part:)
      case part
      when 1 then bingo.first_board.score
      when 2 then bingo.last_board.score
      end
    end

    def numbers
      @numbers ||= lines.first.split(",").map(&:to_i)
    end

    def boards
      @boards ||= lines.drop(1).each_slice(6).map { |slice| Board.new(slice.drop(1)) }
    end

    def bingo
      @bingo ||= Bingo.new(numbers, boards)
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

      def first_board
        @first_board ||= begin
          play_turn until @boards.any?(&:complete?)
          @boards.select(&:complete?).first
        end
      end

      def last_board
        @last_board ||= begin
          first_board
          play_turn until @boards.one?(&:incomplete?)
          boards.select(&:incomplete?).first.tap do |board|
            play_turn until board.complete?
          end
        end
      end
    end

    class Board
      attr_reader :rows, :cols

      def initialize(lines)
        @values = lines.flat_map { |line| line.gsub("  ", " ").split(" ").map(&:to_i) }
        @rows = [[], [], [], [], []]
        @cols = [[], [], [], [], []]
      end

      def inspect
        [
          "<Board",
          @values.each_slice(5).map { |row| "  " + row.map { |val| val.nil? ? "x" : val }.join(" ") }.join("\n"),
          ">"
        ].join("\n")
      end

      def call(number)
        return if complete?

        index = @values.index(number)
        return if index.nil?

        row, col = index.divmod(5)
        @rows[row] << number
        @cols[col] << number
        @values[index] = nil
        @number = number
      end

      def complete?
        @complete ||= [*@rows, *@cols].any? { |row| row.size == 5 }
      end

      def incomplete?
        !complete?
      end

      def score
        @values.compact.sum * @number
      end
    end
  end
end
