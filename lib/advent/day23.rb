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
      when 1 then crab_cup_game.advance_by(100).to_s
      when 2 then mega_crab_cup_game.advance_by(10**7).product_of_next_two
      end
    end

    def crab_cup_game
      CrabCupGame.new @labels
    end

    def mega_crab_cup_game
      MegaCrabCupGame.new @labels, 10**6
    end

    class CrabCup < Struct.new(:label)
      attr_accessor :next

      def array_of_next(number)
        number.times.reduce([]) do |array, _|
          [*array, (array.last || self).next]
        end
      end
    end

    class CrabCupGame
      attr_accessor :current

      def initialize(labels)
        @size = labels.size
        @cup_lookup = build_cup_lookup_from labels
        @current = cup_for labels.first
      end

      def build_cup_lookup_from(labels)
        labels
          .cycle
          .take(@size + 1)
          .each_cons(2)
          .each_with_object(Hash.new) do |(label, next_label), memo|
            memo[label] ||= CrabCup.new(label)
            memo[next_label] ||= CrabCup.new(next_label)
            memo[label].next = memo[next_label]
        end
      end

      def cup_for(label)
        @cup_lookup[label]
      end

      def to_s
        cup_for(1).array_of_next(8).map(&:label).join("")
      end

      def product_of_next_two
        cup_for(1).array_of_next(2).map(&:label).reduce(&:*)
      end

      def inspect
        cups = "(#{@current.label}) #{current.array_of_next(8).map(&:label).join(" ")}"
        "cups: #{cups}\npick up: #{pick_up.map(&:label)}\ndestination: #{destination.label}"
      end

      def pick_up
        @current.array_of_next 3
      end

      def destination
        label = subtract_one_from @current.label
        while pick_up.map(&:label).include? label
          label = subtract_one_from label
        end
        cup_for label
      end

      def subtract_one_from(label)
        label == 1 ? @size : label - 1
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

    class MegaCrabCupGame < CrabCupGame
      def initialize(labels, total_cups)
        @size = total_cups
        labels = [*labels, *((labels.size + 1)..@size).to_a]
        @cup_lookup = build_cup_lookup_from labels
        @current = cup_for labels.first
      end
    end
  end
end

