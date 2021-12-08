require "solver"

module Year2021
  class Day06 < Solver
    def solve(part:)
      lantern_fish_school.tap do |school|
        number_of_days(part: part).times { school.advance }
      end.size
    end

    def number_of_days(part:)
      case part
      when 1 then 80
      when 2 then 256
      end
    end

    def lantern_fish_school
      LanternFishSchool.new(raw_input)
    end

    class LanternFishSchool
      def initialize(fish_string)
        @fishes = 9.times.map { |index| fish_string.count(index.to_s) }
      end

      def advance
        @fishes = [*@fishes.drop(1).take(6), @fishes[0] + @fishes[7], @fishes.last, @fishes.first]
      end

      def size
        @fishes.sum
      end
    end
  end
end
