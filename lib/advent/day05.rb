require 'advent/day'

module Advent
  class Day05 < Advent::Day
    DAY = "05"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def initialize(input)
      @seats = input.map { |string| Seat.new(string) }
    end

    def solve(part:)
      case part
      when 1 then max_seat_id
      when 2 then my_seat_id
      end
    end

    def ordered_seat_ids
      @ordered_seat_ids ||= @seats.map(&:seat_id).sort
    end

    def max_seat_id
      ordered_seat_ids.last
    end

    def my_seat_id
      ordered_seat_ids.each_cons(2).each do |(id, next_id)|
        return id + 1 if next_id - id == 2
      end
    end

    class Seat
      attr_reader :row, :col

      def initialize(string)
        arr = string.split("")
        @row = int_from_string arr.take(7), "B", 7
        @col = int_from_string arr.drop(7), "R", 3
      end

      def seat_id
        8 * @row + @col
      end

      def int_from_string(arr, char, len)
        arr.map.with_index { |ch, idx| ch == char ? 2**(len - 1 - idx) : 0 }.sum
      end
    end
  end
end

