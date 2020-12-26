require 'solver'

module Year2020
  class Day19 < Solver
    def part_one
      matching_rule 0
    end

    def part_two
      modified_matching_rule_zero
    end

    def raw_rules
      @raw_rules ||= chunks.first.split("\n")
    end

    def messages
      @messages ||= chunks.last.split("\n")
    end

    def matching_rule(index)
      messages.count { |message| rule_lookup[index].full_match message }
    end

    def modified_matching_rule_zero
      rule_zero = ModifiedRuleZero.new(rule_lookup)
      messages.count { |message| rule_zero.full_match message }
    end

    def rule_lookup
      @rule_lookup ||= raw_rules.each_with_object(Hash.new) do |raw_rule, lookup|
        index, rule_text = raw_rule.split(": ")
        lookup[index.to_i] = Rule.for(rule_text)
      end.tap do |lookup|
        lookup.each { |_index, rule| rule.rule_lookup = lookup }
      end
    end

    class Rule
      attr_accessor :rule_lookup

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
          section.map { |index| rule_lookup[index].to_s }.join("")
        end
      end

      def to_s
        "(#{formatted_sections.join("|")})"
      end
    end

    class ModifiedRuleZero < Rule
      def initialize(rule_lookup)
        @rule_42 = rule_lookup[42]
        @rule_31 = rule_lookup[31]
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

