require 'advent/day'

module Advent
  class Day02 < Advent::Day
    DAY = "02"

    def self.sanitized_input
      raw_input.split("\n").map(&method(:sanitize_line))
    end

    def self.line_regex
      @line_regex = Regexp.new(/(?<lower>\d+)\-(?<upper>\d+) (?<char>\w)\: (?<password>\w+)/)
    end

    def self.sanitize_line(line)
      match = line_regex.match line
      [:lower, :upper, :char, :password].each_with_object(Hash.new) do |key, memo|
        memo[key] = match[key]
      end
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then valid_count policy: LegacyPasswordPolicy
      when 2 then valid_count policy: PasswordPolicy
      end
    end

    def valid_count(policy:)
      @input.count { |hash| policy.new(hash).valid? }
    end

    class LegacyPasswordPolicy
      def initialize(hash)
        @lower, @upper, @char, @password = hash.slice(:lower, :upper, :char, :password).values
      end

      def valid?
        @lower.to_i <= char_count && char_count <= @upper.to_i
      end

      def char_count
        @char_count ||= @password.count @char
      end
    end

    class PasswordPolicy < LegacyPasswordPolicy
      def valid?
        char_at?(@lower) ^ char_at?(@upper)
      end

      def char_at?(index)
        @password[index.to_i - 1] == @char
      end
    end
  end
end
