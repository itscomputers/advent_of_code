require 'advent/day'

module Advent
  class Day16 < Advent::Day
    DAY = "16"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then invalid_values.sum
      when 2 then my_departures.reduce(&:*)
      end
    end

    def rule_regex
      @rule_regex ||= Regexp.new /(?<name>[\w ]+)\: (?<range_1>\d+\-\d+) or (?<range_2>\d+\-\d+)/
    end

    def ticket_regex
      @ticket_regex ||= Regexp.new /\d+\,[\d\,?]+/
    end

    def rules
      @rules ||= @input.map do |row|
        match = rule_regex.match row
        Rule.new(match[:name], match[:range_1], match[:range_2]) if match
      end.compact
    end

    def tickets
      @tickets ||= @input
        .select { |row| ticket_regex.match row }
        .map { |row| Ticket.new row.split(",").map(&:to_i), rules }
    end

    def my_ticket
      tickets.first
    end

    def other_tickets
      tickets.drop 1
    end

    def invalid_values
      other_tickets.flat_map { |ticket| ticket.invalid_values }
    end

    def valid_tickets
      [my_ticket, *other_tickets.reject(&:invalid?)]
    end

    def rule_index_hash
      RuleOrderDeducer.new(rules, valid_tickets).deduce_all.index_hash
    end

    def my_departures
      rule_index_hash
        .select { |rule, _index| rule.name.start_with? 'departure' }
        .map { |_rule, index| my_ticket.numbers[index] }
    end


    class Rule
      attr_reader :name, :ranges

      def initialize(name, *ranges)
        @name = name
        @ranges = ranges.map { |string| string.split("-").map(&:to_i) }
      end

      def valid?(number)
        @ranges.any? { |range| number.between? *range }
      end
    end

    class Ticket
      attr_reader :numbers

      def initialize(numbers, rules)
        @numbers = numbers
        @rules = rules
      end

      def invalid_values
        @invalid_values ||= numbers.select { |number| !@rules.any? { |rule| rule.valid? number } }
      end

      def invalid?
        !invalid_values.empty?
      end

      def possible_rules
        @numbers.map do |number|
          @rules.select { |rule| rule.valid? number }
        end
      end
    end

    class RuleOrderDeducer
      attr_reader :possible_rules, :index_hash

      def initialize(rules, tickets)
        @rules = rules
        @tickets = tickets
        @index_hash = Hash.new
        @possible_rules = @tickets.reduce(Array.new(@rules.size) { @rules }) do |array, ticket|
          array.zip(ticket.possible_rules).map do |(rules, possible_rules)|
            rules & possible_rules
          end
        end
      end

      def deduce_all
        deduce until newly_deduced.empty?
        self
      end

      def newly_deduced
        @newly_deduced ||= @possible_rules
          .each_with_index
          .select { |rules_array, index| rules_array.size == 1 }
          .map { |rules_array, index| [rules_array.first, index] }
      end

      def record!
        newly_deduced.each { |rule, index| @index_hash[rule] = index }
      end

      def filter!
        @possible_rules = @possible_rules.map do |rules_array|
          rules_array - newly_deduced.map(&:first)
        end
        @newly_deduced = nil
      end

      def deduce
        record!
        filter!
      end
    end
  end
end

