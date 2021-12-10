require "solver"

class Array
  def median(&block)
    sorted_array = map { |element| block.call(element) }.sort
    middle_index = sorted_array.size / 2
    sorted_array[middle_index]
  end
end

module Year2021
  class Day10 < Solver
    def solve(part:)
      case part
      when 1 then corrupted_lines.sum(&:syntax_error_score)
      when 2 then incomplete_lines.median(&:score)
      end
    end

    def line_parsers
      @line_parsers ||= lines.map { |line| LineParser.new(line) }
    end

    def corrupted_lines
      line_parsers.select(&:corrupted?)
    end

    def incomplete_lines
      line_parsers.reject(&:corrupted?)
    end

    class LineParser
      OPENING = {
        "(" => ")",
        "[" => "]",
        "{" => "}",
        "<" => ">",
      }

      CLOSING = OPENING.invert

      SCORE = {
        ")" => { :completion => 1, :corruption => 3 },
        "]" => { :completion => 2, :corruption => 57 },
        "}" => { :completion => 3, :corruption => 1197 },
        ">" => { :completion => 4, :corruption => 25137 },
      }

      attr_reader :corrupted_char

      def initialize(line)
        @chars = line.chars
        @remaining = []
      end

      def parse!
        process(@chars.shift) until !@corrupted.nil? || @chars.empty?
      end

      def corrupted?
        parse!
        !@corrupted.nil?
      end

      def completion
        return if corrupted?
        @remaining.reverse.map { |char| OPENING[char] }
      end

      def syntax_error_score
        return 0 unless corrupted?
        SCORE[@corrupted][:corruption]
      end

      def score
        completion.reduce(0) { |acc, char| 5 * acc + SCORE[char][:completion] }
      end

      def process(char)
        if OPENING.keys.include?(char)
          @remaining << char
        elsif CLOSING[char] == @remaining.last
          @remaining.pop
        else
          @corrupted = char
        end
      end
    end
  end
end
