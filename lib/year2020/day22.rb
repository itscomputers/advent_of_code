require 'solver'

module Year2020
  class Day22 < Solver
    def solve(part:)
      combat(part).new(decks).play.winning_score
    end

    def combat(part)
      case part
      when 1 then Combat
      when 2 then RecursiveCombat
      end
    end

    def decks
      chunks.map { |player_string| Deck.new cards_from(player_string) }
    end

    def cards_from(player_string)
      player_string.split("\n").drop(1).map(&:to_i)
    end

    class Deck
      attr_reader :cards

      def initialize(cards)
        @cards = cards
      end

      def draw
        @cards.first
      end

      def cycle(cards)
        @cards = [*@cards.drop(1), *cards]
      end

      def score
        @cards.reverse.each_with_index.reduce(0) do |acc, (card, index)|
          acc + card * (index + 1)
        end
      end
    end

    class Combat
      def initialize(decks)
        @decks = decks
      end

      def draw
        @cards = @decks.map(&:draw)
      end

      def cycle_cards
        @decks.zip(round_result).each do |deck, cards|
          deck.cycle cards
        end
      end

      def play_round
        draw
        cycle_cards
        self
      end

      def play
        play_round until game_over?
        self
      end

      def round_result_for(index)
        index == 0 ? [@cards, []] : [[], @cards.reverse]
      end

      def round_winner
        @cards == @cards.sort ? 1 : 0
      end

      def round_result
        round_result_for round_winner
      end

      def game_over?
        @winner || @decks.any? { |deck| deck.cards.size == 0 }
      end

      def winning_deck
        @winning_deck ||= @decks.find { |deck| deck.cards.size > 0 }
      end

      def winner
        @winner || @decks.index(winning_deck)
      end

      def winning_score
        winning_deck.score
      end
    end

    class RecursiveCombat < Combat
      def configurations
        @configurations ||= Set.new
      end

      def add_configuration?
        configurations.add? @decks.first.cards
      end

      def round_winner
        return super unless recurse?
        recursive_winner
      end

      def recursive_winner
        RecursiveCombat
          .new(@decks.zip(@cards).map { |deck, count| Deck.new deck.cards.drop(1).take(count) })
          .play
          .winner
      end

      def play_round
        return @winner = 0 unless add_configuration?
        super
      end

      def recurse?
        @decks.zip(@cards).all? { |deck, card| deck.cards.size > card }
      end
    end
  end
end

