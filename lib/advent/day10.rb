require 'advent/day'

module Advent
  class Day10 < Advent::Day
    DAY = "10"

    def self.sanitized_input
      raw_input.split("\n").map(&:to_i)
    end

    def initialize(input)
      sorted_input = input.sort
      @voltage_values = [0, *sorted_input, sorted_input.last + 3]
    end

    def solve(part:)
      case part
      when 1 then distribution[1] * distribution[3]
      when 2 then VoltageTree.new(@voltage_values).build.leaf_count
      end
    end

    def differences
      @voltage_values.each_cons(2).map { |(a, b)| b - a }
    end

    def distribution
      @distribution ||= differences.each_with_object(Hash.new { |h, k| h[k] = 0 }) do |diff, memo|
        memo[diff] += 1
      end
    end

    class VoltageTree
      def initialize(voltage_values)
        @voltages = voltage_values.map { |value| Voltage.new value }
        @root = @voltages.first
      end

      def build
        until @voltages.empty?
          current = @voltages.shift
          @voltages
            .take(3)
            .select { |voltage| voltage.value - current.value < 4 }
            .each { |voltage| current.add_child voltage }
        end
        self
      end

      def leaf_count
        @root.leaf_count
      end

      class Voltage
        attr_reader :value, :children

        def initialize(value)
          @value = value
          @children = []
        end

        def add_child(voltage)
          @children << voltage
        end

        def leaf_count
          @leaf_count ||= @children.empty? ? 1 : @children.sum(&:leaf_count)
        end
      end
    end
  end
end

