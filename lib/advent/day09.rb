require 'advent/day'

module Advent
  class Day09 < Advent::Day
    DAY = "09"

    def self.sanitized_input
      raw_input.split("\n").map(&:to_i)
    end

    def self.options
      { :block_length => 25 }
    end

    def initialize(input, block_length:)
      @numbers = input
      @original = input.take block_length
      @remaining = input.drop block_length
      @block = Block.new @original
    end

    def solve(part:)
      case part
      when 1 then first_invalid
      when 2 then range_summing_to_invalid.minmax.sum
      end
    end

    def first_invalid
      @first_invalid ||= begin
        while @block.valid? @remaining.first
          @block.shift! @remaining.shift
        end
        @remaining.first
      end
    end

    def minmax
      @minmax ||= @numbers.minmax
    end

    def min
      minmax.first
    end

    def max
      minmax.last
    end

    def contiguous_length_min
      [first_invalid / max, 2].max
    end

    def contiguous_length_max
      [first_invalid / min, @numbers.size].min
    end

    def range_summing_to_invalid
      (contiguous_length_min..contiguous_length_max).each do |length|
        @numbers.each_cons(length).each do |contiguous_set|
          return contiguous_set if contiguous_set.sum == first_invalid
        end
      end
    end

    class Block
      attr_reader :numbers

      def initialize(numbers)
        @numbers = numbers
        numbers_hash
      end

      def numbers_hash
        @numbers_hash ||= @numbers
          .combination(2)
          .each_with_object(Hash.new { |h, k| h[k] = [] }) do |pair, memo|
            memo[pair.first] << pair.sum
        end
      end

      def sums
        numbers_hash.values.flatten.to_set
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
  end
end

