require 'advent/day'

module Advent
  class Day06 < Advent::Day
    DAY = "06"

    def self.sanitized_input
      raw_input.split("\n\n")
    end

    def initialize(input)
      @groups = input.map { |string| Group.new(string) }
    end

    def solve(part:)
      case part
      when 1 then total_yes_count
      when 2 then total_common_yes_count
      end
    end

    def total_yes_count
      @groups.sum { |group| group.unique_answers.count }
    end

    def total_common_yes_count
      @groups.sum { |group| group.common_answers.count }
    end

    class Group
      def initialize(string)
        @answers = string.split("\n")
      end

      def unique_answers
        @answers.inject(Set.new) do |set, answer|
          set + answer.split("")
        end
      end

      def common_answers
        @answers.inject(('a'..'z').to_set) do |set, answer|
          set & answer.split("")
        end
      end
    end
  end
end

