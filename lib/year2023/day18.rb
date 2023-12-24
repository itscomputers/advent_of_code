require "solver"
require "vector"
require "grid"
require "point"
require "year2023/day10"

module Year2023
  class Day18 < Solver
    def solve(part:)
      case part
      when 1 then Trench.new(instructions).volume
      when 2 then Trench.new(correct_instructions).volume
      else nil
      end
    end

    def instructions
      lines.map { |line| Instruction.build(line) }
    end

    def correct_instructions
      lines.map { |line| Instruction.build_from_hex(line) }
    end

    def trench
      Trench.new(instructions)
    end

    class Trench
      def initialize(instructions)
        @instructions = instructions
        @position = [0, 0]
      end

      def boundary
        @boundary ||= @instructions.reduce(Array.new) do |array, instruction|
          @position = Vector.add(@position, Vector.scale(instruction.direction, instruction.distance))
          array << (@position)
          array
        end
      end

      def volume
        interior_volume + boundary_length / 2 + 1
      end

      def boundary_length
        [*boundary, boundary.first].each_cons(2).reduce(0) do |acc, points|
          acc + Point.distance(*points)
        end
      end

      def interior_volume
        boundary.size.times.map do |i|
          y(i) * (x(i - 1) - x(i + 1))
        end.sum / 2
      end

      def x(index)
        boundary[index % boundary.size].first
      end

      def y(index)
        boundary[index].last
      end
    end

    class Instruction < Struct.new(:direction, :distance)
      def self.build(line)
        char, distance, _ = line.split(" ")
        new(
          direction(char),
          distance.to_i,
        )
      end

      def self.build_from_hex(line)
        hex = line.split(" ").last.delete_prefix("(").delete_suffix(")")
        build("#{char(hex)} #{hex[1..5].to_i(16)} (#{hex})")
      end

      def self.direction(char)
        case char
        when "R" then [1, 0]
        when "L" then [-1, 0]
        when "U" then [0, -1]
        when "D" then [0, 1]
        else raise ArgumentError
        end
      end

      def self.char(hex)
        case hex[-1]
        when "0" then "R"
        when "1" then "D"
        when "2" then "L"
        when "3" then "U"
        else raise ArgumentError
        end
      end
    end
  end
end
