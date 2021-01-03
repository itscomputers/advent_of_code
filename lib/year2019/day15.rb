require 'solver'
require 'vector'
require 'tree'
require 'year2019/intcode_computer'

module Year2019
  class Day15 < Solver
    def part_one
      droid_mover.explore
      droid_mover.distance_to_oxygen
    end

    def part_two
      droid_mover.max_distance_from_oxygen
    end

    def droid_mover
      @droid_mover ||= DroidMover.new program
    end

    def program
      raw_input.chomp.split(",").map(&:to_i)
    end

    class DroidMover
      def initialize(program)
        @computer = IntcodeComputer.new program
        @environment = { [0, 0] => '.' }
        @position = [0, 0]
        @distances = { [0, 0] => 0 }
      end

      def display!
        system "clear"
        puts [
          "part one: find the oxygen container marked by '$'",
          "part two: explore entire space and calculate time it will take to fill with oxygen",
          "",
          "distance: #{distance}",
          "oxygen distance: #{distance_to_oxygen}",
          "max distance from oxygen: #{@max_distance_from_oxygen}",
          "",
          Grid.display(
            { **@environment, @position => "@" },
            :type => :hash,
          ),
          "",
          "move: h, j, k, l;  quit: q;  calculate: c",
        ].join("\n")
      end

      def explore
        @paused = false
        advance until @paused
      end

      def advance
        display!
        input = STDIN.getch
        if %w(h j k l).include? input
          handle_input(input)
          handle_output
        elsif input == "q"
          @paused = true
        elsif input == "c"
          @max_distance_from_oxygen = max_distance_from_oxygen
        end
      end

      def handle_input(input)
        @computer.next_input do |computer|
          movement_info = movement_info_for input
          computer.add_input movement_info[:input]
          @next_position = Vector.add @position, movement_info[:vector]
        end
      end

      def handle_output
        case @computer.next_output
        when 0 then set_environment(@next_position, "#")
        when 1 then set_environment(@next_position, ".").move
        when 2 then set_environment(@next_position, "$").move.oxygen_position = @next_position
        end
      end

      def move
        @distances[@next_position] ||= distance + 1
        @position = @next_position
        self
      end

      def distance
        @distances[@position]
      end

      def set_environment(position, char)
        @environment[position] = char
        self
      end

      def oxygen_position=(position)
        @oxygen_position = position
        self
      end

      def distance_to_oxygen
        @distances[@oxygen_position]
      end

      def movement_info_for(char)
        {
          "h" => { :input => 3, :vector => [-1, 0] },
          "j" => { :input => 2, :vector => [0, 1] },
          "k" => { :input => 1, :vector => [0, -1] },
          "l" => { :input => 4, :vector => [1, 0] },
        }[char]
      end

      def max_distance_from_oxygen
        return unless @oxygen_position
        distances = @environment.reject { |point, char| char == "#" }.transform_values { nil }
        frontier = [@oxygen_position]
        distances[@oxygen_position] = 0
        until distances.values.none?(&:nil?)
          current = frontier.shift
          [[0, 1], [0, -1], [1, 0], [-1, 0]]
            .map { |dir| Vector.add current, dir }
            .select { |point| distances.key?(point) && distances[point].nil? }
            .each { |point| frontier << point; distances[point] = distances[current] + 1 }
        end
        distances.values.max
      end
    end
  end
end

