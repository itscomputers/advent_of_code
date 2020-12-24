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
      when 1 then crab_cup_game.advance_by(100).part_one
      when 2 then mega_crab_cup_game.advance_by(10**7).part_two
      end
    end

    def crab_cup_game
      CrabCupGame.new @labels
    end

    def mega_crab_cup_game
      CrabCupGame.new @labels + ((@labels.size + 1)..10**6).to_a
    end

    class CrabCupGame
      def initialize(labels)
        @labels = labels
        @size = labels.size
        @state = Array.new
        [*labels, labels.first].each_cons(2) { |(label, next_label)| @state[label] = next_label }
        @current = labels.first
      end

      def inspect
        [
          "cups: (#{@current}) #{array_of_next(@current, 8).join(" ")}",
          "pick up: #{pick_up.join(", ")}",
          "destination: #{destination}",
        ].join("\n")
      end

      def part_one
        array_of_next(1, 8).join("")
      end

      def part_two
        array_of_next(1, 2).reduce(&:*)
      end

      def array_of_next(cup, number)
        number.times.reduce([]) do |array, _|
          [*array, next_after(array.last || cup)]
        end
      end

      def pick_up
        array_of_next(@current, 3)
      end

      def next_after(cup)
        @state[cup] || cup + 1
      end

      def destination
        label = subtract_one_from @current
        while pick_up.include? label
          label = subtract_one_from label
        end
        label
      end

      def subtract_one_from(label)
        label == 1 ? @size : label - 1
      end

      def advance
        p = pick_up
        d = destination

        @state[@current] = @state[p.last]
        @state[p.last] = @state[d]
        @state[d] = p.first
        @current = @state[@current]
        self
      end

      def advance_by(number)
        number.times { advance }
        self
      end
    end
  end
end

