require 'advent/day'

module Advent
  class Day23 < Advent::Day
    DAY = "23"

    def self.sanitized_input
      raw_input.chomp.chars.map(&:to_i)
    end

    def initialize(input)
      @labels = input
    end

    def solve(part:)
      case part
      when 1 then crab_cups.to_s
      end
    end

    def crab_cups
      CrabCups.new(@labels).advance_by(100)
    end

    class CrabCup < Struct.new(:label)
      attr_accessor :next
    end

    class CrabCups
      attr_accessor :current

      def initialize(cup_labels)
        @size = cup_labels.size
        @cup_lookup = cup_labels
          .cycle
          .take(@size + 1)
          .each_cons(2)
          .each_with_object(Hash.new) do |(label, next_label), memo|
            memo[label] ||= CrabCup.new(label)
            memo[next_label] ||= CrabCup.new(next_label)
            memo[label].next = memo[next_label]
        end
        @current = cup_for cup_labels.first
      end

      def cup_for(label)
        @cup_lookup[label]
      end

      def to_s
        cups_after(1, 8).map(&:label).join("")
      end

      def cups_after(label, number)
        number.times.reduce([cup_for(label)]) do |array, _|
          [*array, array.last.next]
        end.drop(1)
      end

      def inspect
        cups = "(#{current.label}) #{cups_after(current.label, 8).map(&:label).join(" ")}"
        "cups: #{cups}\npick up: #{pick_up.map(&:label)}\ndestination: #{destination.label}"
      end

      def pick_up
        cups_after(current.label, 3)
      end

      def remaining_labels
        (1..@size).to_a - pick_up.map(&:label)
      end

      def destination
        cup_for(
          remaining_labels
            .sort
            .reverse.cycle(2 * @size)
            .drop_while { |label| label != @current.label }
            .drop(1)
            .first
        )
      end

      def advance
        @pick_up = pick_up
        @destination = destination

        @current.next = @pick_up.last.next
        @pick_up.last.next = @destination.next
        @destination.next = @pick_up.first
        @current = @current.next
        self
      end

      def advance_by(number)
        number.times { advance }
        self
      end
    end

    class MegaCrabCups
      def initialize(cup_labels, total_cups)
        @cup_labels = cup_labels + (cup_labels.size..total_cups).to_a
        super
      end
    end
  end
end

