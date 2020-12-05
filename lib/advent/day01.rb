require "advent/day"

module Advent
  class Day01 < Advent::Day
    DAY = "01"

    def self.sanitized_input
      raw_input.split("\n").map(&:to_i)
    end

    def self.options
      { :sum => 2020 }
    end

    def initialize(input, sum:)
      @input = input
      @sum = sum
    end

    def solve(part:)
      tuple(size: part + 1).reduce(1) { |acc, val| acc * val }
    end

    def difference_from_sum_hash(size)
      return @difference[size] if @difference&.key? size
      @difference ||= Hash.new
      @difference[size] = @input
        .combination(size - 1)
        .each_with_object(Hash.new) do |values, memo|
          memo[@sum - values.sum] = values
        end
    end

    def tuple(size:)
      @input.each do |value|
        if difference_from_sum_hash(size).key? value
          return [value, *difference_from_sum_hash(size)[value]]
        end
      end
    end
  end
end

