require "solver"

module Year2023
  class Day01 < Solver
    def solve(part:)
      lines.map { |line| extractor(part: part).extract(line) }.sum
    end

    def extractor(part:)
      (part == 1) ? NumberExtractor : RealNumberExtractor
    end

    class NumberExtractor
      PATTERN = /\d/

      def self.patterns
        @patterns ||= [/(#{self::PATTERN}).*$/, /^.*(#{self::PATTERN})/]
      end

      def self.extract(line)
        patterns
          .map { |regex| convert(regex.match(line)[1]) }
          .join
          .to_i
      end

      def self.convert(digit)
        digit
      end
    end

    class RealNumberExtractor < NumberExtractor
      DIGITS = %w[one two three four five six seven eight nine].map.with_index.to_h
      PATTERN = /\d|#{DIGITS.keys.join("|")}/

      def self.convert(digit)
        DIGITS.key?(digit) ? DIGITS[digit] + 1 : digit
      end
    end
  end
end
