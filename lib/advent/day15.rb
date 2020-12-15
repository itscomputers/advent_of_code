require 'advent/day'

module Advent
  class Day15 < Advent::Day
    DAY = "15"

    def self.sanitized_input
      raw_input.split(",").map(&:to_i)
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then MemoryGame.new(@input).play_until(2020).last_spoken
      when 2 then MemoryGame.new(@input).play_until(30000000).last_spoken
      end
    end

    class MemoryGame
      attr_reader :last_spoken

      def initialize(numbers)
        @spoken = numbers[0...-1].each_with_index.to_h
        @last_spoken = numbers.last
        @index = numbers.size - 1
      end

      def next_number
        if @spoken[@last_spoken]
          @index - @spoken[@last_spoken]
        else
          0
        end
      end

      def play_until(index)
        advance while @index + 1 < index
        self
      end

      def advance
        newly_spoken = next_number
        @spoken[@last_spoken] = @index
        @last_spoken = newly_spoken
        @index += 1
        self
      end
    end
  end
end
