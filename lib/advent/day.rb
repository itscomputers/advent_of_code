module Advent
  class Day
    def self.raw_input
      File.read("lib/inputs/#{self::DAY}.txt")
    end

    def self.sanitized_input
      raw_input
    end

    def self.options
      Hash.new
    end

    def self.solve(part:)
      new(sanitized_input, **options).solve(part: part)
    end
  end
end

