require 'io/console'
require 'solver'
require 'year2019/intcode_computer'

module Year2019
  class Day13 < Solver
    def part_one
      arcade_game.play_game.block_count
    end

    def part_two
      arcade_game(coins: 2).play_game.score
    end

    def arcade_game(coins: nil, interactive: false, display: false)
      ArcadeGame.new(program, coins, interactive, display)
    end

    def program
      @program ||= raw_input.split(",").map(&:to_i)
    end

    class ArcadeGame
      def initialize(program, coins, interactive, display)
        @computer = IntcodeComputer.new program
        @computer.set(0, coins) if coins
        @screen_hash = Hash.new
        @outputs = []
        @interactive = interactive
        @display = display
      end

      def inspect
        screen
      end

      def interactive?
        @interactive
      end

      def display?
        @display
      end

      def advance
        if @computer.requires_input?
          handle_input
        elsif @computer.will_output?
          handle_output
        else
          @computer.advance
        end
      end

      def play_game
        advance until @computer.halted?
        self
      end

      def block_count
        @screen_hash.values.count(2)
      end

      def score
        @score
      end

      def screen
        return "new ArcadeGame" if @screen_hash.empty?

        Grid.display(
          @screen_hash,
          :type => 'hash',
          "0" => " ",
          "1" => "|",
          "2" => "+",
          "3" => "_",
          "4" => "o",
        )
      end

      def display!
        return unless display? || interactive?
        system "clear"
        puts "\nscore: #{score}\n#{screen}\n"
      end

      def store_outputs
        *position, value = @outputs
        if position == [-1, 0]
          @score = value
        else
          @screen_hash[position] = value
        end
        @outputs = []
      end

      def process_outputs
        if @outputs.size == 3
          store_outputs
          display!
        end
      end

      def handle_output
        @outputs << @computer.next_output
        process_outputs
      end

      def handle_input
        @computer.next_input do |computer|
          computer.add_input input_value
        end
      end

      def input_value
        interactive? ? interactive_input : automatic_input
      end

      def interactive_input
        { 'h' => -1, 'l' => 1 }.fetch STDIN.getch, 0
      end

      def automatic_input
        if paddle < ball
          1
        elsif paddle > ball
          -1
        else
          0
        end
      end

      def paddle
        @screen_hash.key(3).first
      end

      def ball
        @screen_hash.key(4).first
      end
    end
  end
end

