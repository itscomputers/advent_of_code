require 'advent/day'

module Advent
  class Day22 < Advent::Day
    DAY = "22"

    def self.sanitized_input
      raw_input.split("\n\n")
    end

    def initialize(input)
      @player_strings = input
    end

    def solve(part:)
      case part
      when 1 then Combat.new(decks).play.winning_score
      when 2 then RecursiveCombat.new(decks).play.winning_score
      end
    end

    def decks
      @player_strings.map { |player_string| Deck.new cards_from(player_string) }
    end

    def cards_from(player_string)
      player_string.split("\n").drop(1).map(&:to_i)
    end

    class Deck
      attr_reader :cards

      def initialize(cards)
        @cards = cards
      end

      def inspect
        "#{@cards.join(",")}"
      end

      def draw
        @cards.shift
      end

      def add(cards)
        @cards += cards
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

      def inspect
        "<#{@decks.map(&:inspect).join(" -- ")} prev=#{@cards}>"
      end

      def draw
        @cards = @decks.map(&:draw)
      end

      def round_result_for(index)
        index == 0 ? [@cards, []] : [[], @cards.reverse]
      end

      def player_two_new_cards
        @cards.reverse
      end

      def round_result
        @cards == @cards.sort ? round_result_for(1) : round_result_for(0)
      end

      def cycle_cards
        @decks.zip(round_result).each do |deck, cards|
          deck.add cards
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

    class GameLog
      def initialize
        @hash = Hash.new
      end

      def result_for(cards_array)
        if @hash.key? cards_array
          @hash[cards_array]
        elsif @hash.key? cards_array.reverse
          1 - @hash[cards_array]
        end
      end

      def record(cards_array, winner)
        @hash[cards_array] = winner
      end
    end

    class RecursiveCombat < Combat
      def game_log
        @game_log ||= GameLog.new
      end

      def game_log=(value)
        @game_log = value
      end

      def configurations
        @configurations ||= Set.new
      end

      def previously_seen?
        configurations.include? @decks.map(&:cards)
      end

      def add_configuration
        configurations.add @decks.map(&:cards)
      end

      def round_result
        return super unless recurse?
        round_result_for(recursive_winner)
      end

      def recursive_winner
        cards_array = @decks.zip(@cards).map { |deck, card| deck.cards.take(card) }
        winner_index = game_log.result_for cards_array
        return winner_index unless winner_index.nil?

        RecursiveCombat
          .new(cards_array.map { |cards| Deck.new cards })
          .tap { |recursive_combat| recursive_combat.game_log = game_log }
          .play
          .winner
          .tap { |winner| game_log.record cards_array, winner }
      end

      def play_round
        if previously_seen?
          @winner = 0
          return
        end
        add_configuration
        super
      end

      def recurse?
        @decks.zip(@cards).all? { |deck, card| deck.cards.size >= card }
      end
    end
  end
end

