require 'advent/day'

module Advent
  class Day19 < Advent::Day
    DAY = "19"

    def self.sanitized_input
      raw_input.split("\n\n").map { |chunk| chunk.split("\n") }
    end

    attr_reader :messages

    def initialize(input)
      @raw_rules, @messages = input
    end

    def solve(part:)
      case part
      when 1 then matching_rule 0
      end
    end

    def matching_rule(index)
      @messages.count { |message| rule_hash[index].regex.match message }
    end

    def rule_hash
      @rule_hash ||= build_rule_hash
    end

    def build_rule_hash
      @raw_rules.each_with_object(Hash.new) do |raw_rule, memo|
        index, rule_text = raw_rule.split(": ")
        memo[index.to_i] = Rule.for(rule_text)
      end.tap do |hash|
        hash.each { |_index, rule| rule.rule_hash = hash }
      end
    end

    class Rule
      attr_accessor :rule_hash

      def self.simple_rule
        @simple_rule ||= Regexp.new /\"(?<letter>[a-z])\"/
      end

      def self.for(text)
        match = simple_rule.match(text)
        match ? SimpleRule.new(match[:letter]) : CompoundRule.new(text)
      end

      def regex
        @regex ||= Regexp.new /^#{self}$/
      end
    end

    class SimpleRule < Rule
      def initialize(letter)
        @letter = letter
      end

      def to_s
        @letter
      end
    end

    class CompoundRule < Rule
      def initialize(text)
        @sections = text.split(" | ").map { |section| section.split(" ").map(&:to_i) }
      end

      def formatted_sections
        @sections.map do |section|
          section.map { |index| rule_hash[index].to_s }.join("")
        end
      end

      def to_s
        "(#{formatted_sections.join("|")})"
      end
    end
  end
end

