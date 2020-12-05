require 'advent/day'

module Advent
  class Day04 < Advent::Day
    DAY = "04"

    def self.sanitized_input
      raw_input.split("\n\n").map do |passport|
        passport.gsub("\n", " ").split(" ").each_with_object(Hash.new) do |key_value, memo|
          key, value = key_value.split(":")
          memo[key] = value
        end
      end
    end

    def initialize(input)
      @passports = input.map { |hash| Passport.new(hash) }
    end

    def solve(part:)
      case part
      when 1 then valid_count policy: SimplePolicy
      when 2 then valid_count policy: ComplexPolicy
      end
    end

    def valid_count(policy:)
      @passports.count { |passport| policy.new.valid?(passport) }
    end

    class Passport
      attr_reader :hash

      def initialize(hash)
        @hash = hash
      end

      def valid?(policy:)
        policy.valid? self
      end
    end

    class SimplePolicy
      def required_fields
        @required_fields ||= [
          "byr",
          "iyr",
          "eyr",
          "hgt",
          "hcl",
          "ecl",
          "pid",
        ]
      end

      def valid?(passport)
        required_fields.all? { |key| passport.hash.key? key }
      end
    end

    class ComplexPolicy < SimplePolicy
      def valid?(passport)
        required_fields.all? { |key| self.send key, passport.hash[key] }
      end

      def between?(value, lower, upper)
        lower <= value.to_i && value.to_i <= upper
      end

      def byr(value)
        between? value, 1920, 2002
      end

      def iyr(value)
        between? value, 2010, 2020
      end

      def eyr(value)
        between? value, 2020, 2030
      end

      def hgt_regex
        @hgt_regex ||= Regexp.new(/(?<number>\d+)(?<unit>cm|in)/)
      end

      def hgt(value)
        match = hgt_regex.match(value)
        return false if match.nil?
        case match[:unit]
        when "cm" then between? match[:number], 150, 193
        when "in" then between? match[:number], 59, 76
        else false
        end
      end

      def hcl_regex
        @hcl_regex ||= Regexp.new(/\#([0-9]|[a-f]){6}/)
      end

      def hcl(value)
        !hcl_regex.match(value).nil?
      end

      def ecl_values
        @ecl_values ||= Set.new %w(amb blu brn gry grn hzl oth)
      end

      def ecl(value)
        ecl_values.include? value
      end

      def pid_regex
        @pid_reges ||= Regexp.new(/^\d{9}$/)
      end

      def pid(value)
        !pid_regex.match(value).nil?
      end
    end
  end
end

