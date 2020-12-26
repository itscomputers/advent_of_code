require 'solver'

module Year2020
  class Day05 < Solver
    def ids
      @ids ||= raw_input.split("\n").map do |string|
        string.gsub(/[BFRL]/, **bitmap).to_i(2)
      end.sort
    end

    def part_one
      ids.last
    end

    def part_two
      ids.each_cons(2).each do |(id, next_id)|
        return id + 1 if next_id - id == 2
      end
    end

    def bitmap
      @bitmap ||= ["B", "F", "R", "L"].zip([1, 0, 1, 0]).to_h
    end
  end
end

