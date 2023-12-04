require "solver"

module Year2023
  class Day04 < Solver
    def solve(part:)
      case part
      when 1 then scratchers.map(&:score).sum
      when 2 then counts.values.sum
      else nil
      end
    end

    def scratchers
      @scratchers ||= lines.map { |line| Scratcher.build(line) }
    end

    def counts
      result = scratchers.size.times.map { |idx| [idx, 1] }.to_h
      scratchers.each_with_index do |scratcher, index|
        scratcher.count.times do |offset|
          result[index + offset + 1] += result[index]
        end
      end
      result
    end

    class Scratcher
      attr_reader :count

      def self.build(line)
        new(*line.split(": ").last.split(" | ").map { |seq| Set.new(seq.split(" ")) })
      end

      def initialize(winners, numbers)
        @count = (winners & numbers).size
      end

      def score
        @count == 0 ? 0 : 2 ** (@count - 1)
      end
    end
  end
end
