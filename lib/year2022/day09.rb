require "point"
require "set"
require "solver"
require "vector"

module Year2022
  class Day09 < Solver
    def solve(part:)
      rope_movement(part: part).execute.visited.size
    end

    def motions
      lines.map do |line|
        dir, count = line.split(" ")
        RopeMotion.new(dir, count.to_i)
      end
    end

    def rope_movement(part:)
      case part
      when 1 then RopeMovement.new(motions, RopeState.new([0, 0], [0, 0]))
      when 2 then RopeMovement.new(motions, LongRopeState.new(10.times.map { [0, 0] }))
      end
    end

    class RopeMovement
      attr_reader :visited

      def initialize(motions, state)
        @motions = motions
        @state = state
        @visited = Set.new([@state.tail])
      end

      def process_motion
        @motions.shift.moves.map do |direction|
          @state.move_head(direction)
          @state.move_tail
          @visited.add(@state.tail)
        end
      end

      def execute
        process_motion until @motions.empty?
        self
      end
    end

    class RopeState < Struct.new(:head, :tail)
      def move_head(direction)
        self.head = Vector.add(head, direction)
      end

      def move_tail
        return if Point.neighbors_of(head, strict: false).include?(tail)
        self.tail = Vector.add(tail, direction)
      end

      def direction
        Vector.subtract(head, tail).map do |coordinate|
          coordinate % 2 == 0 ? coordinate / 2 : coordinate
        end
      end
    end

    class LongRopeState
      def initialize(positions)
        @states = positions.each_cons(2).map do |head, tail|
          RopeState.new(head, tail)
        end
      end

      def head
        @states.first.head
      end

      def tail
        @states.last.tail
      end

      def move_head(direction)
        @states.first.head = Vector.add(@states.first.head, direction)
      end

      def move_tail
        [*@states, nil].each_cons(2) do |prev_state, next_state|
          prev_state.move_tail
          next_state.head = prev_state.tail unless next_state.nil?
        end
      end
    end

    class RopeMotion < Struct.new(:dir, :count)
      def direction
        @direction ||= {
          "R" => [1, 0],
          "L" => [-1, 0],
          "U" => [0, -1],
          "D" => [0, 1],
        }.dig(dir)
      end

      def moves
        count.times.map { direction }
      end
    end
  end
end
