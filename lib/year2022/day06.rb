require "solver"

module Year2022
  class Day06 < Solver
    def solve(part:)
      case part
      when 1 then marker(4)
      when 2 then marker(14)
      end
    end

    def data_stream
      @data_stream ||= lines.first.chars
    end

    def marker(uniq_count)
      data_stream.each_cons(uniq_count).with_index do |slice, index|
        return index + uniq_count if slice.uniq == slice
      end
    end
  end
end
