require "solver"

module Year2021
  class Day14 < Solver
    def solve(part:)
      polymer_formula.advance_until(step: part == 1 ? 10 : 40).diff
    end

    def polymer_formula
      @polymer_formula ||= PolymerFormula.from(lines)
    end

    class PolymerFormula
      REGEX = /(\w{2}) -> (\w)/

      def self.from(lines)
        new(
          lines.first,
          lines.drop(2).map do |line|
            REGEX.match(line).to_a.drop(1)
          end.to_h,
        )
      end

      attr_reader :pair_counts

      def initialize(template, insertion_rules)
        @pair_counts = template.chars.each_cons(2).map(&:join).counts_hash
        @insertion_rules = insertion_rules
        @step = 0
      end

      def new_pairs(pair)
        a, b = pair.chars
        [a, @insertion_rules.dig(pair), b].compact.each_cons(2).map(&:join)
      end

      def modifications
        @pair_counts.keys.reduce(Hash.new(0)) do |hash, pair|
          next hash unless @insertion_rules.key?(pair)
          hash[pair] -= @pair_counts[pair]
          new_pairs(pair).each do |new_pair|
            hash[new_pair] += @pair_counts[pair]
          end
          hash
        end
      end

      def advance
        modifications.map do |pair, value|
          @pair_counts[pair] = (@pair_counts[pair] || 0) + value
        end
        @step += 1
      end

      def advance_until(step:)
        advance until @step == step
        self
      end

      def counts
        @pair_counts.reduce(Hash.new(0)) do |hash, (pair, count)|
          pair.chars.each do |char|
            hash[char] += count
          end
          hash
        end
      end

      def diff
        counts.values.map { |v| (v / 2.0).ceil }.minmax.reverse.reduce(:-)
      end
    end
  end
end

class Array
  def counts_hash
    reduce(Hash.new(0)) do |hash, element|
      hash[element] += 1
      hash
    end
  end
end
