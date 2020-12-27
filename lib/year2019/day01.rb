require 'solver'

module Year2019
  class Day01 < Solver
    def part_one
      numbers.map(&method(:fuel)).sum
    end

    def part_two
      numbers.map(&method(:fuel_for_fuel)).sum
    end

    def numbers
      @numbers ||= lines.map(&:to_i)
    end

    def fuel(mass)
      (mass / 3) - 2
    end

    def fuel_for_fuel(mass, acc=-mass)
      return acc if mass <= 0
      fuel_for_fuel(fuel(mass), acc + mass)
    end
  end
end

