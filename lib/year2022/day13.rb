require "json"
require "solver"

module Year2022
  class Day13 < Solver
    def solve(part:)
      case part
      when 1 then comparisons.map.with_index.sum { |comp, index| comp == -1 ? index + 1 : 0 }
      when 2 then decoder_keys.reduce(&:*)
      end
    end

    def packet_pairs
      @packet_pairs ||= chunks.map do |chunk|
        chunk.split("\n").map { |line| JSON.parse(line) }
      end
    end

    def comparisons
      packet_pairs.map { |pair| compare(*pair) }
    end

    def divider_packets
      [[[2]], [[6]]]
    end

    def ordered_packets
      @ordered_packets ||= [*packet_pairs.flatten(1), *divider_packets].sort(&method(:compare))
    end

    def decoder_keys
      divider_packets.map { |packet| ordered_packets.index(packet) + 1 }
    end

    def compare(array, other)
      return 0 if array.empty? && other.empty?
      return -1 if array.empty?
      return 1 if other.empty?

      if array.first.is_a?(Integer) && other.first.is_a?(Integer)
        comp = array.first <=> other.first
      elsif array.first.is_a?(Integer)
        comp = compare([[array.first], *array.drop(1)], other)
      elsif other.first.is_a?(Integer)
        comp = compare(array, [[other.first], *other.drop(1)])
      else
        comp = compare(array.first, other.first)
      end

      comp == 0 ? compare(array.drop(1), other.drop(1)) : comp
    end
  end
end
