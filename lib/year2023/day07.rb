require "solver"

module Year2023
  class Day07 < Solver
    def solve(part:)
      case part
      when 1 then score(camel_hands)
      when 2 then score(wild_hands)
      else nil
      end
    end

    def camel_hands
      lines.map { |line| CamelHand.build(line) }
    end

    def wild_hands
      lines.map { |line| WildHand.build(line) }
    end

    def score(hands)
      hands.sort.map.with_index { |hand, index| hand.bid * (index + 1) }.sum
    end

    class CamelHand
      include Comparable

      attr_reader :bid

      def self.build(line)
        cards, bid = line.split(" ")
        new(cards.chars, bid.to_i)
      end

      def initialize(cards, bid)
        @cards = cards
        @bid = bid
      end

      def value(card)
        case card
        when "T" then "A"
        when "J" then "B"
        when "Q" then "C"
        when "K" then "D"
        when "A" then "E"
        else card
        end
      end

      def values
        @values ||= @cards.map(&method(:value)).join
      end

      def counts
        @cards.counter
      end

      def distribution
        @distribution ||= counts.values.counter
      end

      def rank
        return @rank unless @rank.nil?
        @rank = 1 if distribution == {1 => 5}
        @rank = 2 if distribution == {2 => 1, 1 => 3}
        @rank = 3 if distribution == {2 => 2, 1 => 1}
        @rank = 4 if distribution == {3 => 1, 1 => 2}
        @rank = 5 if distribution == {3 => 1, 2 => 1}
        @rank = 6 if distribution == {4 => 1, 1 => 1}
        @rank = 7 if distribution == {5 => 1}
        @rank
      end

      def <=>(other)
        [rank, values] <=> [other.rank, other.values]
      end
    end

    class WildHand < CamelHand
      def value(card)
        card == "J" ? "0" : super(card)
      end

      def counts
        hash = @cards.counter
        if hash.key?("J") && hash != {"J" => 5}
          max_key = hash
            .reject { |k, _| k == "J" }
            .max_by { |_, v| v }
            .first
          hash[max_key] += hash.delete("J")
        end
        hash
      end
    end
  end
end

class Array
  def counter
    reduce(Hash.new) do |acc, item|
      acc[item] = (acc[item] || 0) + 1
      acc
    end
  end
end
