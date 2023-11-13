require "solver"

module Year2021
  class Day21 < Solver
    def solve(part:)
      case part
      when 1 then game.losing_score * game.dice_count
      when 2 then quantum_game_universe.win_count
      end
    end

    def positions
      @positions ||= lines.map do |line|
        line.match(/starting position: (?<pos>\d+)/)[:pos].to_i
      end
    end

    def game
      @game ||= DiracGame.new(positions).execute
    end

    def quantum_game_universe
      QuantumDiracUniverse.new(positions).execute
    end

    class DiracPlayer < Struct.new(:position, :score)
      def roll(total)
        self.position = (self.position + total - 1) % 10 + 1
        self.score += self.position
      end

      def split
        (3..9).zip([1, 3, 6, 7, 6, 3, 1]).flat_map do |(total, count)|
          count.times.map do
            copy.tap { |player| player.roll(total) }
          end
        end
      end

      def copy
        DiracPlayer.new(self.position, self.score)
      end
    end

    class DiracGame
      def initialize(positions)
        @players = [
          DiracPlayer.new(positions.first, 0),
          DiracPlayer.new(positions.last, 0),
        ]
        @turn = 0
      end

      def execute
        execute_turn until finished?
        self
      end

      def execute_turn
        player.roll(total)
        @turn += 1
      end

      def player
        @players[@turn % 2]
      end

      def total
        6 + 9 * @turn
      end

      def finished?
        @players.any? { |player| player.score >= 1000 }
      end

      def losing_score
        @players.map(&:score).min
      end

      def dice_count
        @turn * 3
      end
    end

    class QuantumDiracUniverse
      def initialize(positions)
        game = Game.new(positions.map { |position| DiracPlayer.new(position, 0) }, 0)
        @unfinished_games = {game => 1}
        @wins = [0, 0]
      end

      def execute
        execute_turn until @unfinished_games.empty?
        self
      end

      def win_count
        @wins.max
      end

      def execute_turn
        @unfinished_games = @unfinished_games.reduce(
          Hash.new { |h, k| h[k] = 0 }
        ) do |hash, (unfinished_game, count)|
          unfinished_game.split.each do |game|
            if game.finished?
              @wins[1 - game.turn] += count
            else
              hash[game] += count
            end
          end
          hash
        end
      end

      class Game < Struct.new(:players, :turn)
        def finished?
          players.any? { |player| player.score >= 21 }
        end

        def player
          players[turn]
        end

        def opponent
          players[1 - turn]
        end

        def split
          player.split.map do |p|
            players = [p, opponent.copy]
            players.reverse! if turn == 1
            Game.new(players, 1 - turn)
          end
        end
      end
    end
  end
end
