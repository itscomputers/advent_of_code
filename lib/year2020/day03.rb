require 'solver'
require 'grid_parser'

module Year2020
  class Day03 < Solver
    def lines
      @lines ||= raw_input.split("\n")
    end

    def bounds
      @bounds ||= [lines.first.size, lines.size]
    end

    def trees
      @trees ||= GridParser.new(lines: lines).parse_as_set(char: "#")
    end

    def slopes(part:)
      case part
      when 1 then [[3, 1]]
      when 2 then [[1, 1], [3, 1], [5, 1], [7, 1], [1, 2]]
      end
    end

    def solve(part:)
      tree_count_product slopes(part: part)
    end

    def tree_count(slope)
      (bounds.last / slope.last).times.count do |idx|
        trees.include? [(idx * slope.first) % bounds.first, idx * slope.last]
      end
    end

    def tree_count_product(slopes)
      slopes.reduce(1) { |acc, slope| acc * tree_count(slope) }
    end
  end
end

