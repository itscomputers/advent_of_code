require "solver"

module Year2023
  class Day02 < Solver
    def solve(part:)
      case part
      when 1 then games.select(&:valid?).map(&:id).sum
      when 2 then games.map(&:power).sum
      else nil
      end
    end

    def games
      @games ||= lines.map { |line| Game.build(line) }
    end

    class Game
      attr_reader :id

      def self.build(line)
        game_str, sets = line.split(":")
        new(extract_id(game_str)).tap do |game|
          sets.split(";").each do |bag_set_str|
            game.process_bag_set(extract_counts(bag_set_str))
          end
        end
      end

      def self.extract_counts(bag_set_str)
        %w(blue red green).map do |color|
          m = bag_set_str.match(/(\d+) #{color}/)
          m.nil? ? 0 : m[0].to_i
        end
      end

      def self.extract_id(game_str)
        game_str.split(" ").last.to_i
      end

      def initialize(id)
        @id = id
        @valid = true
        @maxes = [0, 0, 0]
      end

      def process_bag_set(colors)
        invalidate!(colors)
        update_maxes!(colors)
      end

      def invalidate!(colors)
        if colors.zip([14, 12, 13]).any? { |(val, max)| val > max }
          @valid = false
        end
      end

      def update_maxes!(colors)
        colors.zip(@maxes).each_with_index do |pair, index|
          @maxes[index] = pair.max
        end
      end

      def valid?
        @valid
      end

      def power
        @maxes.reduce(&:*)
      end
    end
  end
end
