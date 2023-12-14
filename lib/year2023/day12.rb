require "solver"

module Year2023
  class Day12 < Solver
    COUNTS_BY_STATE = Hash.new

    def solve(part:)
      case part
      when 1 then arrangements.map(&:count).sum
      when 2 then unfolded_arrangements.map(&:count).sum
      else nil
      end
    end

    def get_springs(line)
      line.split(" ").first
    end

    def get_sizes(line)
      line.split(" ").last.split(",").map(&:to_i)
    end

    def arrangements
      lines.map { |line| Arrangement.build(get_springs(line), get_sizes(line)) }
    end

    def unfolded_arrangements
      lines.map { |line| Arrangement.unfold(get_springs(line), get_sizes(line)) }
    end

    class Arrangement < Struct.new(:springs, :sizes, :damaged_count)
      def self.build(springs, sizes)
        new(springs, sizes, 0)
      end

      def self.unfold(springs, sizes)
        new(
          5.times.map { springs }.join("?"),
          5.times.flat_map { sizes },
          0,
        )
      end

      def count
        return get_count if count_cached?
        springs.empty? ? set_terminal_count : set_non_terminal_count
        get_count
      end

      def set_terminal_count
        if damaged_count > 0
          set_count(sizes.size == 1 && end_damaged? ? 1 : 0)
        else
          set_count(sizes.empty? ? 1 : 0)
        end
      end

      def set_non_terminal_count
        set_count(chars.map(&method(:next_count)).sum)
      end

      def next_count(char)
        char == "#" ? next_count_damaged : next_count_operational
      end

      def next_count_damaged
        Arrangement.new(springs[1..], sizes, damaged_count + 1).count
      end

      def next_count_operational
        if damaged_count == 0
          Arrangement.new(springs[1..], sizes, damaged_count).count
        elsif end_damaged?
          Arrangement.new(springs[1..], sizes.drop(1), 0).count
        else
          0
        end
      end

      def end_damaged?
        sizes.first == damaged_count
      end

      def chars
        springs.chr == "?" ? %w(# .) : [springs.chr]
      end

      def count_cached?
        COUNTS_BY_STATE.key?(self)
      end

      def get_count
        COUNTS_BY_STATE[self]
      end

      def set_count(count)
        COUNTS_BY_STATE[self] = count
      end
    end
  end
end
