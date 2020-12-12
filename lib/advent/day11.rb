require 'advent/day'
require 'util'

module Advent
  class Day11 < Advent::Day
    DAY = "11"

    def self.sanitized_input
      raw_input.split("\n").flat_map.with_index do |row, y|
        row.split("").map.with_index do |char, x|
          point = Point.new(x, y)
          [point, Location.new(point, char)]
        end
      end.to_h
    end

    def initialize(input)
      @location_hash = input
    end

    def solve(part:)
      case part
      when 1 then stable_occupied_count neighbor_method: 'neighbors'
      when 2 then stable_occupied_count neighbor_method: 'line_of_sight'
      end
    end

    def reset!
      @stable = false
      @location_hash.values.each(&:reset!)
    end

    def stable_occupied_count(neighbor_method:)
      reset!
      advance(neighbor_method) until @stable
      @location_hash.values.count(&:occupied?)
    end

    def location_at(point)
      @location_hash[point]
    end

    def occupied_count_hash(neighbor_method)
      @location_hash.values.each_with_object(Hash.new) do |location, memo|
        memo[location] = location.send(neighbor_method, @location_hash).count(&:occupied?)
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
      ].map { |arr| Point.new(*arr) }

      def initialize(point, char)
        @point = point
        @original_char = char
        @char = char
      end

      def reset!
        @char = @original_char
      end

      def inspect
        "<Location x=#{@point.x} y=#{@point.y} char=#{@char}>"
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

      def neighbors(location_hash)
        @neighbors ||= DIRECTIONS.map { |point| location_hash[@point + point] }.compact
      end

      def line_of_sight(location_hash)
        @line_of_sight ||= DIRECTIONS.map do |direction|
          visible_in_direction direction, location_hash
        end.compact
      end

      def visible_in_direction(direction, location_hash)
        test = @point + direction
        while location_hash[test]&.floor?
          test += direction
        end
        location_hash[test]
      end
    end
  end
end

