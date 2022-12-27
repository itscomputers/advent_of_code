require "solver"

module Year2022
  class Day20 < Solver
    def solve(part:)
      file(part: part).mix.grove_coordinates.sum
    end

    def file(part: 1)
      case part
      when 1 then File.new(lines.map(&:to_i))
      when 2 then EncryptedFile.new(lines.map(&:to_i))
      end
    end

    class File
      def initialize(sequence)
        @sequence = sequence
        @size = sequence.size
        @indices = (0...@size).to_a
        @sequence_index = 0
        @index = 0
      end

      def sequence_value_at(index)
        @sequence[index]
      end

      def offset
        sequence_value_at(@sequence_index)
      end

      def destination
        1 + (@index + offset - 1) % (@size - 1)
      end

      def move_next
        @indices.insert(destination, @indices.delete_at(@index))
        @sequence_index += 1
        set_index
        self
      end

      def mix
        move_next until @sequence_index == @size
        self
      end

      def set_index
        @index = @indices.index(@sequence_index)
      end

      def state
        @indices.map(&method(:sequence_value_at))
      end

      def grove_coordinates
        start = @indices.index(@sequence.index(0))
        (1..3).map do |multiplier|
          sequence_value_at(@indices[(start + 1000 * multiplier) % @size])
        end
      end
    end

    class EncryptedFile < File
      def sequence_value_at(index)
        super * 811589153
      end

      def reset_indices
        @sequence_index = 0
        set_index
      end

      def mix
        10.times { |i| super and reset_indices }
        self
      end
    end
  end
end

