require 'solver'

module Year2020
  class Day06 < Solver
    def groups
      @groups ||= raw_input.split("\n\n").map { |string| Group.new(string) }
    end

    def part_one
      groups.sum { |group| group.unique_answers.size }
    end

    def part_two
      groups.sum { |group| group.common_answers.size }
    end

    class Group
      def initialize(string)
        @answers = string.split("\n")
      end

      def unique_answers
        @answers.inject(Set.new) do |set, answer|
          set + answer.chars
        end
      end

      def common_answers
        @answers.inject(('a'..'z').to_set) do |set, answer|
          set & answer.chars
        end
      end
    end
  end
end

