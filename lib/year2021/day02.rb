require "solver"
require "Vector"

module Year2021
  class Day02 < Solver
    def solve(part:)
      case part
      when 1 then commands.reduce([0, 0]) { |location, command| Vector.add(location, command.to_a) }.reduce(:*)
      when 2 then Location.new.tap { |location| commands.each { |command| location.advance(command) } }.to_a.reduce(:*)
      end
    end

    def commands
      @commands ||= lines.map { |line| Command.from(line) }
    end

    class Command
      attr_reader :horizontal, :aim

      REGEX = /(?<direction>(forward|down|up)) (?<quantity>\d*)/

      def self.from(string)
        match = REGEX.match(string)
        direction = match[:direction]
        quantity = match[:quantity]

        case direction
        when "forward" then new(quantity.to_i, 0)
        when "down" then new(0, quantity.to_i)
        when "up" then new(0, -quantity.to_i)
        end
      end

      def initialize(horizontal, aim)
        @horizontal = horizontal
        @aim = aim
      end

      def to_a
        [@horizontal, @aim]
      end
    end

    class Location
      def initialize
        @horizontal = 0
        @depth = 0
        @aim = 0
      end

      def advance(command)
        @horizontal += command.horizontal
        @aim += command.aim
        @depth += (command.horizontal * @aim)
      end

      def to_a
        [@horizontal, @depth]
      end
    end
  end
end
