require 'solver'
require 'vector'

module Year2019
  class Day03 < Solver
    def part_one
      intersection_points.map { |point| Vector.norm point }.min
    end

    def part_two
      intersection_points.map do |point|
        wires.sum { |wire| wire.signal_delay_lookup[point] }
      end.min
    end

    def parse_line(line)
      Wire.new line
    end

    def wires
      parsed_lines
    end

    def intersection_points
      @intersection_points ||= wires.map(&:points).reduce(:&)
    end

    class Wire
      def self.move_regex
        @move_regex ||= /(?<direction>[UDLR])(?<number>\d+)/
      end

      def self.directions
        @directions ||= { "R" => [1, 0], "U" => [0, 1], "L" => [-1, 0], "D" => [0, -1] }
      end

      def initialize(string)
        @moves = string.split(",")
      end

      def parse(move)
        match = self.class.move_regex.match move
        [
          self.class.directions[match[:direction]],
          match[:number].to_i,
        ]
      end

      def signal_delay_lookup
        return @signal_delay_lookup unless @signal_delay_lookup.nil?

        signal_delay = 0
        curr = [0, 0]

        @signal_delay_lookup = @moves.each_with_object(Hash.new) do |move, hash|
          direction, number = parse(move)
          (1..number).each do |index|
            curr = Vector.add curr, direction
            hash[curr] ||= signal_delay + index
          end
          signal_delay += number
        end
      end

      def points
        signal_delay_lookup.keys
      end
    end
  end
end

