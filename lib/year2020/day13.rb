require 'solver'
require 'chinese_remainder_theorem'

module Year2020
  class Day13 < Solver
    def part_one
      earliest_bus_and_time.reduce(&:*)
    end

    def part_two
      ChineseRemainderTheorem.new(residues, moduli).solution
    end

    def earliest_departure
      @earliest_departure ||= lines.first.to_i
    end

    def buses
      @buses ||= lines.last.split(",").map do |string|
        string == "x" ? nil : string.to_i
      end
    end

    def period
      buses.compact.reduce(&:lcm)
    end

    def local_departure
      earliest_departure % period
    end

    def buses_and_wait_times
      buses.compact.map { |bus| [bus, bus - local_departure % bus] }
    end

    def earliest_bus_and_time
      buses_and_wait_times.min_by(&:last)
    end

    def moduli
      buses.compact
    end

    def residues
      buses.map.with_index { |bus, index| bus.nil? ? nil : -index }.compact
    end
  end
end

