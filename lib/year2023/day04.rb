require "solver"

module Year2023
  class Day04 < Solver
    def solve(part:)
      case part
      when 1 then scratchers.map(&:score).sum
      when 2 then multiplier.multiply.total_count
      else nil
      end
    end

    def scratchers
      @scratchers ||= lines.map { |line| Scratcher.build(line) }
    end

    def multiplier
      Multiplier.new(scratchers)
    end

    class Scratcher
      attr_reader :id

      def self.build(line)
        new(
          line.split(":").first.split(" ").last.to_i,
          *line.split(":").last.split("|").map do |seq|
            Set.new(seq.split(" ").map(&:to_i))
          end,
        )
      end

      def initialize(id, winners, numbers)
        @id = id
        @winners = winners
        @numbers = numbers
      end

      def count
        (@winners & @numbers).size
      end

      def score
        count == 0 ? 0 : 2 ** (count - 1)
      end
    end

    class Multiplier
      def initialize(scratchers)
        @scratchers = scratchers
        @counts = scratchers.map { |scratcher| [scratcher.id, 1] }.to_h
      end

      def multiply
        @scratchers.each do |scratcher|
          scratcher.count.times do |offset|
            @counts[scratcher.id + offset + 1] += @counts[scratcher.id]
          end
        end
        self
      end

      def total_count
        @counts.values.sum
      end
    end
  end
end
