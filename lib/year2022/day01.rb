require "solver"

module Year2022
  class Day01 < Solver
    def solve(part:)
      case part
      when 1 then calories.max
      when 2 then calories.max(3).sum
      end
    end

    def nested_calories
      @nested_calories ||= chunks.map { |chunk| chunk.split("\n").map(&:to_i) }
    end

    def calories
      @calories ||= nested_calories.map(&:sum)
    end
  end
end
