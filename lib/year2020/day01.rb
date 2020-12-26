require "solver"

module Year2020
  class Day01 < Solver
    def numbers
      @numbers ||= lines.map(&:to_i)
    end

    def sum
      2020
    end

    def solve(part:)
      find_tuple(size: part + 1).reduce(1) { |acc, val| acc * val }
    end

    def difference_from_sum_hash(size)
      return @difference[size] if @difference&.key? size
      @difference ||= Hash.new
      @difference[size] = numbers
        .combination(size - 1)
        .each_with_object(Hash.new) do |values, memo|
          memo[sum - values.sum] = values
        end
    end

    def find_tuple(size:)
      numbers.each do |value|
        if difference_from_sum_hash(size).key? value
          return [value, *difference_from_sum_hash(size)[value]]
        end
      end
    end
  end
end

