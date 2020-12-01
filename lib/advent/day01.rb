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

    def initialize(input, sum)
      @input = input
      @sum = sum
    end

    def solve(part:)
      case part
      when 1 then pair.reduce(1) { |acc, val| acc * val }
      when 2 then trio.reduce(1) { |acc, val| acc * val }
      end
    end

    def pair
      @pair ||= @input.each do |value|
        unless difference_from_sum_hash[value].empty?
          return [value, difference_from_sum_hash[value].first]
        end
      end
    end

    def difference_from_sum_hash
      @difference ||= @input.each_with_object(Hash.new { |h, k| h[k] = [] }) do |value, memo|
        memo[@sum - value] << value
      end
    end

    def pair_difference_from_sum_hash
      @pair_difference ||= @input
        .product(@input)
        .each_with_object(Hash.new { |h, k| h[k] = [] }) do |values, memo|
          if values.uniq == values
            memo[@sum - values.sum] << values
          end
      end
    end

    def trio
      @trio ||= @input.each do |value|
        unless pair_difference_from_sum_hash[value].empty?
          return [value, *pair_difference_from_sum_hash[value].first]
        end
      end
    end
  end
end

