require "solver"

module Year2022
  class Day11 < Solver
    def solve(part:)
      keep_away(part: part)
        .execute(rounds: rounds(part: part))
        .monkeys
        .map(&:inspection_count)
        .max(2)
        .reduce(&:*)
    end

    def monkeys
      chunks.map { |chunk| Monkey.build(chunk) }
    end

    def worry_reduction(part:)
      case part
      when 1 then "simple"
      when 2 then "advanced"
      end
    end

    def keep_away(part:)
      KeepAway.new(monkeys, worry_reduction(part: part))
    end

    def rounds(part:)
      case part
      when 1 then 20
      when 2 then 10000
      end
    end

    class KeepAway
      attr_reader :monkeys

      def initialize(monkeys, worry_reduction)
        @monkeys = monkeys
        @worry_reduction = worry_reduction
      end

      def worry_factor
        @monkeys.map(&:worry_factor).reduce(&:*)
      end

      def worry_operation
        @worry_operation ||= case @worry_reduction
        when "simple" then Operation.new("/", 3)
        when "advanced" then Operation.new("%", worry_factor)
        end
      end

      def state
        @monkeys.map { |monkey| monkey.items.join(", ") }
      end

      def execute(rounds:)
        rounds.times { Round.new(@monkeys, worry_operation).execute }
        self
      end

      class Round
        def initialize(monkeys, worry_operation)
          @monkeys = monkeys
          @worry_operation = worry_operation
          @index = 0
        end

        def monkey
          @monkeys[@index]
        end

        def take_turn
          Turn.new(monkey, @monkeys, @worry_operation).execute
          @index += 1
        end

        def execute
          take_turn until @index == @monkeys.size
        end
      end

      class Turn
        def initialize(monkey, monkeys, worry_operation)
          @monkey = monkey
          @monkeys = monkeys
          @worry_operation = worry_operation
        end

        def inspect_item
          item, index = @monkey.inspect_and_test(@worry_operation)
          @monkeys[index].catch(item)
        end

        def execute
          inspect_item until @monkey.items.empty?
        end
      end
    end

    class Monkey
      attr_reader :inspection_count, :items

      def self.build(chunk)
        Builder.new(chunk).build
      end

      def initialize(items, operation, test)
        @items = items
        @operation = operation
        @test = test
        @inspection_count = 0
      end

      def inspect_and_test(worry_operation)
        @inspection_count += 1
        item = worry_operation.call(@operation.call(@items.shift))
        index = @test.call(item)
        [item, index]
      end

      def catch(item)
        @items << item
      end

      def worry_factor
        @test.divisor
      end

      class Builder
        def initialize(chunk)
          @lines = chunk.split("\n")
        end

        def build
          Monkey.new(items, operation, test)
        end

        def items
          find("Starting items:").scan(/\d+/).map(&:to_i)
        end

        def operation
          line = find("Operation:")
          op = line.match(/(?<op>[\*\+])/)[0]
          value_match = line.match(/(?<value>\d+)/)
          if value_match.nil?
            value = nil
          else
            value = value_match[0]
          end

          Operation.new(op, value)
        end

        def test
          divisor = find("Test:").match(/\d+/)[0].to_i
          values = ["If true:", "If false:"].map do |string|
            find(string).match(/\d+/)[0].to_i
          end
          Test.new(divisor, values)
        end

        def find(string)
          @lines.find { |line| line =~ /#{string}/ }
        end
      end
    end

    class Operation < Struct.new(:op, :value)
      def call(item)
        item.send(op, value_for(item))
      end

      def value_for(item)
        value.nil? ? item : value.to_i
      end
    end

    class Test < Struct.new(:divisor, :values)
      def call(item)
        item % divisor == 0 ? values.first : values.last
      end
    end
  end
end
