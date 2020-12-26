require 'solver'

module Year2020
  class Day02 < Solver
    def line_regex
      @line_regex = Regexp.new(/(?<lower>\d+)\-(?<upper>\d+) (?<char>\w)\: (?<password>\w+)/)
    end

    def parse_line(line)
      match = line_regex.match line
      [:lower, :upper, :char, :password].each_with_object(Hash.new) do |key, memo|
        memo[key] = match[key]
      end
    end

    def lines
      @lines ||= raw_input.split("\n").map(&method(:parse_line))
    end

    def solve(part:)
      case part
      when 1 then valid_count policy: LegacyPasswordPolicy
      when 2 then valid_count policy: PasswordPolicy
      end
    end

    def valid_count(policy:)
      lines.count { |hash| policy.new(hash).valid? }
    end

    class LegacyPasswordPolicy
      def initialize(hash)
        @lower, @upper, @char, @password = hash.slice(:lower, :upper, :char, :password).values
      end

      def valid?
        @password.count(@char).between? @lower.to_i, @upper.to_i
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

