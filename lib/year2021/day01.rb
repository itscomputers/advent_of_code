require "solver"

module Year2021
  class Day01 < Solver
    def solve(part:)
      array(part: part).each_cons(2).count { |(prev, curr)| prev < curr }
    end

    def array(part:)
      case part
      when 1 then lines.map(&:to_i)
      when 2 then lines.each_cons(3).map { |arr| arr.map(&:to_i).sum }
      end
    end
  end
end
