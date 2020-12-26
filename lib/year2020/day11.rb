require 'solver'
require 'vector'

module Year2020
  class Day11 < Solver
    def solve(part:)
      case part
      when 1 then stable_occupied_count neighbor_method: 'neighbors'
      when 2 then stable_occupied_count neighbor_method: 'line_of_sight'
      end
    end

    def location_lookup
      @location_lookup ||= grid_parser.parse_as_hash do |point, char|
        Location.new(point, char)
      end
    end

    def locations
      location_lookup.values
    end

    def reset!
      @stable = false
      locations.each(&:reset!)
    end

    def stable_occupied_count(neighbor_method:)
      reset!
      advance(neighbor_method) until @stable
      locations.count(&:occupied?)
    end

    def occupied_count_hash(neighbor_method)
      locations.each_with_object(Hash.new) do |location, memo|
        memo[location] = location.send(neighbor_method, location_lookup).count(&:occupied?)
      end
    end

    def advance(neighbor_method)
      critical_value = neighbor_method == 'neighbors' ? 3 : 4
      @stable = true
      occupied_count_hash(neighbor_method).each do |location, occupied_count|
        if location.open? && occupied_count == 0
          location.set_type :occupied
          @stable = false
        elsif location.occupied? && occupied_count > critical_value
          location.set_type :open
          @stable = false
        end
      end
      self
    end

    class Location
      attr_reader :point, :char

      TYPE_CHAR = {
        :open => "L",
        :occupied => "#",
        :floor => "."
      }

      DIRECTIONS = [
        [-1, -1], [0, -1], [1, -1],
        [-1,  0],          [1,  0],
        [-1,  1], [0,  1], [1,  1],
      ]

      def initialize(point, char)
        @point = point
        @original_char = char
        @char = char
      end

      def reset!
        @char = @original_char
      end

      def set_type(type)
        @char = TYPE_CHAR[type]
      end

      def occupied?
        @char == "#"
      end

      def open?
        @char == "L"
      end

      def floor?
        @char == "."
      end

      def neighbors(location_lookup)
        @neighbors ||= DIRECTIONS.map { |point| location_lookup[Vector.add @point, point] }.compact
      end

      def line_of_sight(location_lookup)
        @line_of_sight ||= DIRECTIONS.map do |direction|
          visible_in_direction direction, location_lookup
        end.compact
      end

      def visible_in_direction(direction, location_lookup)
        test = Vector.add @point, direction
        while location_lookup[test]&.floor?
          test = Vector.add test, direction
        end
        location_lookup[test]
      end
    end
  end
end

