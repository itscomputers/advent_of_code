require 'solver'

module Year2020
  class Day23 < Solver
    def part_one
      CrabCupGame.new(labels).advance_by(100).part_one
    end

    def part_two
      CrabCupGame.new(
        labels + ((labels.size + 1)..10**6).to_a
      ).advance_by(10**7).part_two
    end

    def labels
      @labels ||= raw_input.chomp.chars.map(&:to_i)
    end

    class CrabCupGame
      def initialize(labels)
        @size = labels.size
        @state = Array.new
        [*labels, labels.first].each_cons(2) { |(label, next_label)| set_next label, next_label }
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
        @state[cup]
      end

      def set_next(cup, next_cup)
        @state[cup] = next_cup
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

        set_next @current, next_after(p.last)
        set_next p.last, next_after(d)
        set_next d, p.first
        @current = next_after @current
        self
      end

      def advance_by(number)
        number.times { advance }
        self
      end
    end
  end
end

