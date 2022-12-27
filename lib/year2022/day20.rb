require "solver"

module Year2022
  class Day20 < Solver
    def solve(part:)
      file(part: part).decrypt.grove_coordinates.sum
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

      def shift
        (@index + offset - 1) / @size
      end

      def destination
        (@index + offset + shift) % @size
      end

      def mix
        @indices = @indices.move_value(from: @index, to: destination)
        @sequence_index += 1
        set_index
        self
      end

      def decrypt
        mix until @sequence_index == @size
        self
      end

      def state
        @indices.map(&method(:sequence_value_at))
      end

      def set_index
        @index = @indices.index(@sequence_index)
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

      def decrypt
        puts "initial state #{state}"
        10.times do |i|
          super
          reset_indices
          puts "state after #{i + 1} mixings: #{state}"
        end
        self
      end
    end
  end
end

class Array
  def move_value(from:, to:)
    case from <=> to
    when 0 then self
    when 1 then [
      *take(to),
      self[from],
      *drop(to).take(from - to),
      *drop(from + 1),
    ]
    when -1 then [
      *take(from),
      *drop(from + 1).take(to - from),
      self[from],
      *drop(to + 1),
    ]
    end
  end
end

