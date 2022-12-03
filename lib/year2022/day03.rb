require "solver"
require "set"

module Year2022
  class Day03 < Solver
    def solve(part:)
      case part
      when 1 then rucksacks.sum(&:priority)
      when 2 then rucksack_groups.sum(&:priority)
      end
    end

    def rucksacks
      @rucksacks ||= lines.map { |line| Rucksack.new(line.chars) }
    end

    def rucksack_groups
      rucksacks.each_slice(3).map { |group| RucksackGroup.new(group) }
    end

    class Rucksack
      attr_reader :items

      def initialize(items)
        @items = items
      end

      def compartments
        [
          @items.take(@items.size / 2),
          @items.drop(@items.size / 2),
        ]
      end

      def common_item
        compartments.reduce(:&).first
      end

      def priority
        [*("a".."z"), *("A".."Z")].index(common_item) + 1
      end
    end

    class RucksackGroup < Rucksack
      def initialize(rucksacks)
        @rucksacks = rucksacks
      end

      def compartments
        @rucksacks.map(&:items)
      end
    end
  end
end
