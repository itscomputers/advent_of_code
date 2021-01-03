require 'solver'
require 'grid'
require 'vector'
require 'point'
require 'year2019/intcode_computer'

module Year2019
  class Day17 < Solver
    def program
      @program ||= raw_input.chomp.split(",").map(&:to_i)
    end

    def part_one
      ascii.alignment_parameters_sum
    end

    def part_two
      IntcodeComputer.new(modified_program).add_input(*inputs).run.output
    end

    def ascii
      @ascii ||= ASCII.new(program)
    end

    def movement_instructions
      ScaffoldVisitor.new(ascii).movement_instructions
    end

    def inputs
      InputsBuilder.new(movement_instructions).inputs
    end

    def modified_program
      [2, *program.drop(1)]
    end

    class ASCII
      def initialize(program)
        @program = program
      end

      def computer
        @computer ||= IntcodeComputer.new @program
      end

      def view
        @view ||= computer.run.outputs.map(&:chr)
      end

      def print_view
        puts view.join('')
      end

      def lines
        view.join('').split
      end

      def grid
        @grid ||= Grid.parse lines, as: :hash
      end

      def scaffold_at?(point)
        grid[point] == '#'
      end

      def scaffold
        @scaffold ||= grid.keys.select { |k| grid[k] == '#' }
      end

      def initial_position
        grid.keys.find { |k| %w(< ^ > v).include? grid[k] }
      end

      def initial_direction
        {
          '<' => [-1, 0],
          '^' => [0, -1],
          '>' => [1, 0],
          'v' => [0, 1],
        }[grid[initial_position]]
      end

      def scaffold_intersections
        @intersections ||= scaffold.select do |point|
          (Point.neighbors_of(point) & scaffold).count == 4
        end
      end

      def alignment_parameters_sum
        scaffold_intersections.map { |(x, y)| x * y }.sum
      end
    end

    class ScaffoldVisitor
      attr_reader :movement_instructions

      def initialize(ascii)
        @ascii = ascii
        @position = ascii.initial_position
        @direction = ascii.initial_direction
        @movement_instructions = []
        @end_of_path = false
      end

      def forward_one
        Vector.add @position, @direction
      end

      def can_move_forward_one?
        @ascii.scaffold_at? forward_one
      end

      def move_forward_one
        @position = forward_one
      end

      def detect_distance_and_move
        distance = 0
        loop do
          if can_move_forward_one?
            move_forward_one
            distance += 1
          else
            break
          end
        end
        @movement_instructions << distance if distance > 0
      end

      def left_turn
        Point.rotate @direction, :ccw
      end

      def right_turn
        Point.rotate @direction, :cw
      end

      def can_turn_left?
        @ascii.scaffold_at? Vector.add @position, left_turn
      end

      def can_turn_right?
        @ascii.scaffold_at? Vector.add @position, right_turn
      end

      def turn_left
        @movement_instructions << 'L'
        @direction = left_turn
      end

      def turn_right
        @movement_instructions << 'R'
        @direction = right_turn
      end

      def detect_direction_and_turn
        if can_turn_left?
          turn_left
        elsif can_turn_right?
          turn_right
        else
          @end_of_path = true
        end
      end

      def movement_instructions
        return @movement_instructions unless @movement_instructions.empty?
        until @end_of_path
          detect_direction_and_turn
          detect_distance_and_move
        end
        @movement_instructions
      end
    end

    class InputsBuilder
      attr_reader :instructions, :partition

      def initialize(instructions)
        @instructions = instructions
      end

      def main_routine
        %w(A B A B C A B C A C)
      end

      def movement_functions
        [
          @instructions.slice(0, 6),
          @instructions.slice(6, 8),
          @instructions.slice(28, 8),
        ]
      end

      def insert_commas_and_new_line(array)
        new_array = array.inject([]) { |arr, val| [*arr, val.ord, 44] }
        [*new_array[0...-1], 10]
      end

      def inputs
        validate!
        [
          main_routine.join(","),
          *movement_functions.map { |func| func.join(",") },
          "n",
          "",
        ].join("\n").split("").map(&:ord)
      end

      def validate!
        hash = %w(A B C).zip(movement_functions).each_with_object(Hash.new) do |(letter, func), memo|
          memo[letter] = func
        end
        instructions = main_routine.reduce(Array.new) do |array, letter|
          [*array, *hash[letter]]
        end
        raise ArgumentError unless instructions == @instructions
      end
    end
  end
end



