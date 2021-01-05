require 'solver'
require 'point'

module Year2019
  class Day18 < Solver
    def part_one
      vault.shortest_path_length
    end

    def vault
      @vault ||= Vault.new lines
    end

    class Vault
      attr_reader :lookup, :key_state

      def initialize(lines)
        @lookup = Grid.parse(lines, as: :hash) do |point, char|
          char != "#" ? char : nil
        end.compact
        @bitmap = Hash.new
      end

      def inspect
        "<Vault position=#{initial_position}>"
      end

      def initial_position
        @lookup.key "@"
      end

      def keys
        @keys ||= @lookup.select { |point, char| /[a-z]/.match char }.values
      end

      def neighbors_of(point, key_state)
        return [] if door_at?(point) && !unlocked?(char_at(point), key_state)

        Point.neighbors_of(point).select(&method(:on_map?)).map do |neighbor|
          [neighbor, unlock(char_at(point), key_state)]
        end
      end

      def char_at(point)
        @lookup[point]
      end

      def on_map?(point)
        @lookup.key? point
      end

      def door_at?(point)
        !!/[A-Z]/.match(@lookup[point])
      end

      def key_at?(point)
        !!/[a-z]/.match(@lookup[point])
      end

      def unlocked?(char, key_state)
        key_state == key_state | bit_for(char)
      end

      def unlock(char, key_state)
        !/[a-z]/.match(char) || unlocked?(char, key_state) ?
          key_state :
          key_state ^ bit_for(char)
      end

      def bit_for(char)
        @bitmap[char] ||= 1 << (char.downcase.ord - 'a'.ord)
      end

      def all_unlocked_key_state
        @all_unlocked_key_state ||= keys.sum(&method(:bit_for))
      end

      def path_finder
        PathFinder.new(self)
      end

      def shortest_path_length
        path_finder.find_shortest
      end

      class PathFinder
        attr_reader :frontier, :visited

        def initialize(vault)
          @vault = vault
          @frontier = [[vault.initial_position, 0]]
          @visited = Set.new
          @step = 0
        end

        def inspect
          "<PathFinder frontier.size=#{@frontier.size}, visited.size=#{@visited.size}, step=#{@step}>"
        end

        def find_shortest
          advance until @all_keys_collected
          @step - 1
        end

        def already_visited?(neighbor)
          @visited.include? neighbor
        end

        def advance
          @frontier = @frontier.flat_map do |(point, key_state)|
            @visited.add [point, key_state]
            if @vault.all_unlocked_key_state == key_state
              @all_keys_collected = true and return
            end
            @vault.neighbors_of(point, key_state).reject(&method(:already_visited?))
          end.uniq

          @step += 1
          self
        end
      end
    end
  end
end

