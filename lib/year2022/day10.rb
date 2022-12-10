require "solver"
require "grid"

module Year2022
  class Day10 < Solver
    def solve(part:)
      case part
      when 1 then (20..220).step(40).map(&method(:signal_strength)).sum
      when 2 then "\n#{crt_display}\n"
      end
    end

    def register_lookup
      @register_lookup ||= lines.reduce([1]) do |array, line|
        array.push(array.last)
        if line.start_with?("addx")
          array.push(array[-2] + line.split(" ").last.to_i)
        end
        array
      end
    end

    def register(cycle)
      register_lookup[cycle - 1]
    end

    def signal_strength(cycle)
      cycle * register(cycle)
    end

    def point(cycle)
      (cycle - 1).divmod(40).reverse
    end

    def pixel(cycle)
      (register(cycle) - point(cycle).first).abs < 2 ? "#" : "."
    end

    def crt_grid
      (1..240).reduce(Hash.new) do |hash, cycle|
        hash[point(cycle)] = pixel(cycle)
        hash
      end
    end

    def crt_display
      Grid.display(crt_grid, :type => :hash)
    end
  end
end
