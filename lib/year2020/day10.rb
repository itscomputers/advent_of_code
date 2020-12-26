require 'solver'

module Year2020
  class Day10 < Solver
    def voltage_values
      @voltage_values ||= begin
        sorted_values = lines.map(&:to_i).sort
        [0, *sorted_values, sorted_values.last + 3]
      end
    end

    def part_one
      distribution[1] * distribution[3]
    end

    def part_two
      VoltageTree.new(voltage_values).build.leaf_count
    end

    def distribution
      @distribution ||= voltage_values
        .each_cons(2)
        .each_with_object(Hash.new { |h, k| h[k] = 0 }) do |pair, memo|
          memo[pair.last - pair.first] += 1
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

      class Voltage < Struct.new(:value)
        def children
          @children ||= Array.new
        end

        def add_child(voltage)
          children << voltage
        end

        def leaf_count
          @leaf_count ||= [children.sum(&:leaf_count), 1].max
        end
      end
    end
  end
end

