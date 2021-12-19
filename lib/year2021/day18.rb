require "json"
require "solver"

module Year2021
  class Day18 < Solver
    def solve(part:)
      case part
      when 1 then snail_fish_sum.magnitude
      when 2 then max_pair_magnitude
      end
    end

    def parse_line(line)
      JSON.parse(line)
    end

    def snail_fish_numbers
      parsed_lines.map { |array| SnailFishNumber.for(array) }
    end

    def snail_fish_sum
      snail_fish_numbers.drop(1).reduce(snail_fish_numbers.first) { |acc, number| acc + number }
    end

    def max_pair_magnitude
      parsed_lines.permutation(2).map do |(array, other)|
        (SnailFishNumber.for(array) + SnailFishNumber.for(other)).magnitude
      end.max
    end

    class SnailFishNumber
      def self.for(item)
        if item.is_a?(SnailFishNumber)
          item
        elsif item.is_a?(Array)
          Complex.new(item)
        else
          Simple.new(item)
        end
      end

      def root?
        parent.nil?
      end

      def to_s
        inspect
      end

      def left?
        !root? && parent.left == self
      end

      def right?
        !root? && parent.right == self
      end

      def left_regular
        return self if regular?
        @left.left_regular
      end

      def right_regular
        return self if regular?
        return @right if @right.regular?
        @right.right_regular
      end

      def regulars
        return [self] if regular?
        children.compact.flat_map(&:regulars)
      end

      def left_jump
        return if root?
        return parent.left.right_regular if right?
        parent.left_jump
      end

      def right_jump
        return if root?
        return parent if parent.right.nil?
        return parent.right.left_regular if left?
        parent.right_jump
      end

      def replace_with(item)
        return if root?
        SnailFishNumber.for(item).tap do |number|
          number.parent = self.parent
          parent.left = number if left?
          parent.right = number if right?
        end
      end

      def to_a
        JSON.parse(inspect)
      end

      def reduce
        self
      end

      def +(other)
        SnailFishNumber.for([self.to_a, other]).reduce
      end

      class Simple < SnailFishNumber
        attr_accessor :left, :right, :parent

        def initialize(number)
          @left = number
          @right = nil
        end

        def inspect
          value.to_s
        end

        def value
          @left
        end
        alias_method :magnitude, :value

        def children
          []
        end

        def regular?
          true
        end

        def regulars
          [self]
        end

        def pair?
          false
        end

        def split!
          new_left = value / 2
          replace_with([new_left, value - new_left])
        end

        def pairs
          []
        end

        def descendants(depth:)
          []
        end
      end

      class Complex < SnailFishNumber
        attr_accessor :left, :right, :parent

        def initialize(array)
          @left, @right = array.map do |item|
            SnailFishNumber.for(item).tap { |child| child.parent = self }
          end
        end

        def inspect
          return @left.inspect if @right.nil?
          "[#{children.map(&:inspect).join(",")}]"
        end

        def value
          nil
        end

        def children
          [@left, @right]
        end

        def regular?
          false
        end

        def pair?
          children.none?(&:nil?) && children.all?(&:regular?)
        end

        def explode!
          return unless pair?
          if left_jump
            if left_jump.regular?
              left_jump.left += @left.value
            else
              left_jump.right += @left.value
            end
          end
          right_jump&.left += @right.value
          replace_with(0)
        end

        def pairs
          return self if pair?
          children.compact.flat_map(&:pairs)
        end

        def magnitude
          3 * @left.magnitude + 2 * (@right&.magnitude || 0)
        end

        def descendants(depth:)
          return self if depth == 0
          children.compact.flat_map { |child| child.descendants(depth: depth - 1) }
        end

        def explode_candidate
          descendants(depth: 4).flat_map(&:pairs).first
        end

        def split_candidate
          regulars.find { |regular| regular.value > 9 }
        end

        def reduce_single
          explode_candidate.tap do |candidate|
            unless candidate.nil?
              candidate.explode!
              return true
            end
          end
          split_candidate.tap do |candidate|
            unless candidate.nil?
              candidate.split!
              return true
            end
          end
          false
        end

        def reduce
          loop { break unless reduce_single }
          self
        end
      end
    end
  end
end
