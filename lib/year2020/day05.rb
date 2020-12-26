require 'solver'

module Year2020
  class Day05 < Solver
    def parse_line(line)
      line.gsub(/[BFRL]/, **bitmap).to_i 2
    end

    def ids
      @ids ||= parsed_lines.sort
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

