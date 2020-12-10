require 'advent/day'

module Advent
  class Day09 < Advent::Day
    DAY = "09"

    def self.sanitized_input
      raw_input.split("\n").map(&:to_i)
    end

    def self.options
      { :preamble_length => 25 }
    end

    def initialize(input, preamble_length:)
      @numbers = input
      @preamble = Preamble.new input.take preamble_length
      @remaining = input.drop preamble_length
    end

    def solve(part:)
      case part
      when 1 then first_invalid
      when 2 then contiguous_set.minmax.sum
      end
    end

    def first_invalid
      @first_invalid ||= begin
        while @preamble.valid? @remaining.first
          @preamble.shift! @remaining.shift
        end
        @remaining.first
      end
    end

    def contiguous_set
      ContiguousSumSearcher.new(@numbers, first_invalid).search.contiguous_set
    end

    class Preamble
      attr_reader :numbers

      def initialize(numbers)
        @numbers = numbers
        @numbers_hash = @numbers
          .combination(2)
          .each_with_object(Hash.new { |h, k| h[k] = [] }) do |pair, memo|
            memo[pair.first] << pair.sum
        end
      end

      def sums
        @numbers_hash.values.flatten.to_set
      end

      def valid?(number)
        sums.include? number
      end

      def shift!(new_number)
        @numbers_hash.delete @numbers.shift
        @numbers_hash[new_number] = @numbers.map { |number| number + new_number }
        @numbers << new_number
      end
    end

    class ContiguousSumSearcher
      def initialize(numbers, target)
        @numbers = numbers
        @target = target
        @index = 0
        @length = 2
      end

      def search
        continue_search until @search_complete || contiguous_set.empty?
        self
      end

      def contiguous_set
        @numbers.slice(@index, @length)
      end

      def sum
        contiguous_set.sum
      end

      def continue_search
        difference = sum - @target
        if difference < 0
          @length += 1
        elsif difference > 0
          @index += 1
          @length -= 1
        else
          @search_complete = true
        end
      end
    end
  end
end

