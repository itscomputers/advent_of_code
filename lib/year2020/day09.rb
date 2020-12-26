require 'solver'

module Year2020
  class Day09 < Solver
    def part_one
      first_invalid
    end

    def part_two
      contiguous_set.minmax.sum
    end

    def numbers
      @numbers ||= lines.map(&:to_i)
    end

    def preamble_length
      25
    end

    def preamble
      Preamble.new numbers.take(preamble_length)
    end

    def first_invalid
      @first_invalid ||= preamble.first_invalid_from numbers.drop(preamble_length)
    end

    def contiguous_set
      ContiguousSumSearcher.new(numbers, first_invalid).search.contiguous_set
    end

    class Preamble
      attr_reader :numbers

      def initialize(numbers)
        @numbers = numbers
        @number_sum_lookup = @numbers
          .combination(2)
          .each_with_object(Hash.new { |h, k| h[k] = [] }) do |pair, memo|
            memo[pair.first] << pair.sum
        end
      end

      def sums
        @number_sum_lookup.values.flatten.to_set
      end

      def valid?(number)
        sums.include? number
      end

      def shift!(new_number)
        @number_sum_lookup.delete @numbers.shift
        @number_sum_lookup[new_number] = @numbers.map { |number| number + new_number }
        @numbers << new_number
      end

      def first_invalid_from(numbers)
        numbers.each do |number|
          if valid? number
            shift! number
          else
            return number
          end
        end
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
        continue_search until search_complete?
        self
      end

      def search_complete?
        @search_complete || contiguous_set.empty?
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

