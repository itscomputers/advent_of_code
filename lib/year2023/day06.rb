require "solver"

module Year2023
  class Day06 < Solver
    def solve(part:)
      case part
      when 1 then
        times
          .zip(distances)
          .map { |(time, distance)| winning_count(time, distance) }
          .reduce(&:*)
      when 2 then
        winning_count(
          times.join("").to_i,
          distances.join("").to_i,
        )
      else nil
      end
    end

    def times
      @times ||= lines.first&.scan(/\d+/).map(&:to_i)
    end

    def distances
      @distance || lines.last&.scan(/\d+/).map(&:to_i)
    end

    def winning_count(time, distance)
      zero = quadratic_solution(1, -time, distance)
      zero -= 1 if zero.to_i == zero
      2 * zero.to_i - time + 1
    end

    def quadratic_solution(a, b, c)
      (-b + Math.sqrt(b ** 2 - 4 * a * c)) / 2
    end
  end
end
