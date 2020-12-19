require 'advent/day'

module Advent
  class Day19 < Advent::Day
    DAY = "19"

    def self.sanitized_input
      raw_input.split("\n\n").map { |chunk| chunk.split("\n") }
    end

    def initialize(input)
      @raw_rules, @messages = input
    end

    def solve(part:)
      case part
      when 1 then matching_rule 0
      when 2 then modified_matching_rule_zero
      end
    end

    def matching_rule(index)
      @messages.count { |message| rule_hash[index].full_match message }
    end

    def modified_matching_rule_zero
      rule_zero = ModifiedRuleZero.new(rule_hash)
      @messages.count { |message| rule_zero.full_match message }
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

      def match(message)
        regex.match message
      end

      def full_match(message)
        full_regex.match message
      end

      def full_regex
        @full_regex ||= Regexp.new /^#{self}$/
      end

      def regex
        @regex ||= Regexp.new /#{self}/
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

    class ModifiedRuleZero < Rule
      def initialize(rule_hash)
        @rule_42 = rule_hash[42]
        @rule_31 = rule_hash[31]
      end

      def full_match(message)
        right_shape?(message) && rule_zero?(message)
      end

      def right_shape?(message)
        !/^#{@rule_42}{2,}#{@rule_31}+$/.match(message).nil?
      end

      def rule_31_length(message)
        @rule_31_length ||= /#{@rule_31}/.match(message)[1].length
      end

      def rule_zero?(message)
        upper = message.length / rule_31_length(message)
        (1..upper).any? do |rule_11_count|
          /^(#{@rule_42})+#{rule_11(rule_11_count)}$/.match(message)
        end
      end

      def rule_11(times)
        "(#{@rule_42}){#{times}}(#{@rule_31}){#{times}}"
      end
    end
  end
end

