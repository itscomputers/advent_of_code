require "solver"
require "grid"
require "point"

module Year2023
  class Day03 < Solver
    def solve(part:)
      case part
      when 1 then schematic.parts.map(&:value).sum
      when 2 then schematic.gear_ratios.sum
      else nil
      end
    end

    def schematic
      @schematic = Schematic.new(lines)
    end

    class Schematic
      def initialize(lines)
        @lines = lines
      end

      def symbols
        @symbols ||= @lines.each_with_index.reduce(Hash.new) do |hash, (line, row)|
          line.chars.each_with_index do |ch, col|
            if ch != "." && !ch.match(/\d/)
              hash[[row, col]] = Symbol.new(row, col, ch)
            end
          end
          hash
        end
      end

      def numbers
        @numbers ||= @lines.size.times.reduce([]) do |array, row|
          col = 0
          while col < line(row).size
            number = Number.build(row, col, self)
            break if number.nil?
            number.set_symbol(self)
            array << number
            col = number.col + number.length
          end
          array
        end
      end

      def line(row)
        return "" if row < 0
        @lines[row] || ""
      end

      def substring(row, start, stop=-1)
        line(row)[start..stop] || ""
      end

      def char(row, col)
        return "." if col < 0
        line(row)[col] || "."
      end

      def parts
        numbers.select(&:part?)
      end

      def gear_parts
        @gear_parts ||= numbers.to_a.select(&:gear_part?)
      end

      def gear_ratios
        gear_parts.combination(2).map do |part, other|
          part.symbol == other.symbol ? part.value * other.value : 0
        end
      end

      class Number < Struct.new(:row, :col, :value, :length)
        attr_reader :symbol

        def self.build(row, col, schematic)
          m = schematic.substring(row, col).match(/\d+/)
          return if m.nil?
          value = m[0]
          col += schematic.substring(row, col).index(value)
          new(row, col, value.to_i, value.length)
        end

        def set_symbol(schematic)
          [
            [col - 1, row],
            [col + length, row],
            *(col-1..col+length).map { |c| [c, row - 1] },
            *(col-1..col+length).map { |c| [c, row + 1] },
          ].each do |(col, row)|
            schematic.symbols[[row, col]].tap do |symbol|
              @symbol = symbol unless symbol.nil?
            end
          end
        end

        def part?
          !@symbol.nil?
        end

        def gear_part?
          part? && @symbol.value == "*"
        end
      end

      class Symbol < Struct.new(:row, :col, :value)
      end
    end
  end
end
