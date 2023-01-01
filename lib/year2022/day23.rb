require "grid"
require "point"
require "solver"
require "vector"

module Year2022
  class Day23 < Solver
    def solve(part:)
      case part
      when 1 then elf_grid.execute(rounds: 10).empty_count
      when 2 then elf_grid.execute.round
      end
    end

    def elf_grid
      @elf_grid ||= ElfGrid.new(Grid.parse(lines, as: :hash))
    end

    class ElfGrid
      attr_reader :round

      def initialize(grid)
        @grid = grid
        @round = 0
        @directions = [[0, -1], [0, 1], [-1, 0], [1, 0]]
        @stable = false
      end

      def inspect
        "<ElfGrid round=#{@round} empty=#{empty_count}>"
      end

      def display
        puts "\n-----\n\n#{Grid.display(@grid, type: :hash, " " => ".")}\n\n--------\nround: #{@round}"
      end

      def execute_round
        proposed_moves_by_elf.select do |new_position, elf_positions|
          if elf_positions.size == 1
            elf_position = elf_positions.first
            @grid[elf_position] = "."
            @grid[new_position] = "#"
          end
        end
        @directions = @directions.cycle(2).drop(1).take(4)
        @round += 1
        self
      end

      def execute(rounds: nil)
        execute_round until rounds == @round || @stable
        self
      end

      def elf_positions
        @grid.select { |point, char| char == "#" }.keys
      end

      def proposed_move(elf_position)
        ProposedMoveBuilder.new(elf_position, @grid, @directions).build
      end

      def proposed_moves_by_elf
        elf_positions.reduce(Hash.new { |h, k| h[k] = [] }) do |hash, elf_position|
          new_position = proposed_move(elf_position)
          hash[new_position] << elf_position unless new_position.nil?
          hash
        end.tap do |moves|
          @stable = true if moves.empty?
        end
      end

      def empty_count
        Grid.x_range(@grid.keys).sum do |x|
          Grid.y_range(@grid.keys).sum do |y|
            @grid[[x, y]] == "#" ? 0 : 1
          end
        end
      end

      class ProposedMoveBuilder
        def initialize(elf_position, grid, directions)
          @elf_position = elf_position
          @grid = grid
          @directions = directions
        end

        def neighbors
          @neighbors ||= Point
            .neighbors_of(@elf_position, strict: false)
            .select { |point| @grid[point] == "#" }
        end

        def position(direction)
          Vector.add(@elf_position, direction)
        end

        def neighbor_in?(direction)
          neighbors.any? do |neighbor|
            Point.distance(neighbor, position(direction)) <= 1
          end
        end

        def build
          return if neighbors.empty?
          @directions.each do |direction|
            return position(direction) unless neighbor_in?(direction)
          end
          nil
        end
      end
    end
  end
end
