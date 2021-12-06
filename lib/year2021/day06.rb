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
      LanternFishSchool.new(lines.first)
    end

    class LanternFishSchool
      def initialize(fish_string)
        @timers = 9.times.map { |index| fish_string.count(index.to_s) }
      end

      def advance
        @timers = [*@timers.drop(1).take(6), @timers[0] + @timers[7], @timers.last, @timers.first]
      end

      def size
        @timers.sum
      end
    end
  end
end
