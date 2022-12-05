require "solver"

module Year2022
  class Day05 < Solver
    def solve(part:)
      cargo_crane(part: part).execute_moves.configuration.join
    end

    def cargo_crane(part:)
      klass = part == 1 ? CargoCrane9000 : CargoCrane9001
      klass.new(
        Stack.build_all(chunks.first.split("\n")),
        chunks.last.split("\n").map { |raw_move| Move.build(raw_move) },
      )
    end

    class CargoCrane9000
      attr_reader :moves, :stacks

      def initialize(stacks, moves)
        @stacks = stacks
        @moves = moves
      end

      def execute(move)
        move.count.times { target(move).push(source(move).pop) }
      end

      def execute_moves
        execute(@moves.shift) until @moves.empty?
        self
      end

      def configuration
        @stacks.map { |stack| stack.crates.last }
      end

      def source(move)
        @stacks[move.source - 1]
      end

      def target(move)
        @stacks[move.target - 1]
      end
    end

    class CargoCrane9001 < CargoCrane9000
      def execute(move)
        target(move).push(*source(move).pop(move.count))
      end
    end

    class Stack
      attr_reader :crates

      def self.build_all(raw_rows)
        *rows, count_row = raw_rows
        stack_count = count_row.split.map(&:to_i).max
        crate_rows = rows.map do |row|
          stack_count.times.map do |index|
            value = row[1 + 4 * index]
            value == " " ? nil : value
          end
        end
        stack_count.times.map do |index|
          self.new(crate_rows.reverse.map { |crate_row| crate_row[index] }.compact)
        end
      end

      def initialize(crates)
        @crates = crates
      end

      def push(*crates)
        @crates = [*@crates, *crates]
      end

      def pop(count=1)
        @crates.pop(count)
      end
    end

    class Move < Struct.new(:count, :source, :target)
      def self.build(raw_move)
        self.new(*raw_move.split(/move|from|to/).map(&:to_i).drop(1))
      end
    end
  end
end
