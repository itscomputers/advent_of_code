require 'solver'

module Year2019
  class Day04 < Solver
    def part_one
      increasing_passwords.count(&:has_repeat?)
    end

    def part_two
      increasing_passwords.count(&:has_double?)
    end

    def range
      raw_input.chomp.split("-")
    end

    def possible_passwords
      (range.first..range.last).map { |string| Password.new string }
    end

    def increasing_passwords
      @increasing_passwords ||= possible_passwords.select(&:increasing?)
    end

    class Password
      def initialize(string)
        @string = string
      end

      def increasing?
        @string.chars.each_cons(2).reduce(true) { |bool, pair| bool && pair.reduce(:<=) }
      end

      def digit_counts
        @digit_counts ||= @string
          .chars
          .each_with_object(Hash.new { |h, k| h[k] = 0 }) do |char, hash|
            hash[char] += 1
        end
      end

      def has_repeat?
        digit_counts.values.any? { |count| count >= 2 }
      end

      def has_double?
        digit_counts.values.include? 2
      end
    end
  end
end

