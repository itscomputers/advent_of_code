require 'solver'
require 'point'
require 'vector'
require 'year2019/intcode_computer'

module Year2019
  class Day11 < Solver
    def part_one
      EmergencyShipHullPainter.new(program, 0).run.panels_painted
    end

    def part_two
      "\n" + EmergencyShipHullPainter.new(program, 1).run.display
    end

    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end

    class EmergencyShipHullPainter
      def initialize(program, input)
        @computer = IntcodeComputer.new(program).tap do |computer|
          computer.add_input input
        end
        @position = [0, 0]
        @direction = [0, -1]
        @colors = Hash.new
      end

      def paint_panel
        @computer.next_output { |computer| @colors[@position] = computer.output }
        self
      end

      def turn
        @computer.next_output do |computer|
          @direction = Point.rotate @direction, computer.output == 1 ? :cw : :ccw
        end
        self
      end

      def move
        @computer.next_input do |computer|
          @position = Vector.add @position, @direction
          computer.add_input @colors[@position]
        end
        self
      end

      def advance
        paint_panel.turn.move
      end

      def run
        advance until @computer.halted?
        self
      end

      def panels_painted
        @colors.size
      end

      def display
        Range.new(*@colors.keys.map(&:last).minmax).map do |y|
          Range.new(*@colors.keys.map(&:first).minmax).map do |x|
            @colors[[x, y]] == 1 ? "#" : " "
          end.join("")
        end.join("\n")
      end
    end
  end
end

