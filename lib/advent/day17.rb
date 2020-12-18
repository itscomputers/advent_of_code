require 'advent/day'

module Advent
  class Day17 < Advent::Day
    DAY = "17"

    def self.sanitized_input
      raw_input.split("\n").map(&:chars)
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      Grid.new(@input, dimensions: part + 2).advance_by(6).active_cube_count
    end

    class Grid
      attr_reader :point_hash

      def initialize(char_array, dimensions:)
        @dimensions = dimensions
        @point_hash = point_hash_from(char_array)
      end

      def directions
        @directions ||= (@dimensions - 1).times.reduce([-1, 0, 1]) do |array, _|
          [-1, 0, 1].product(array)
        end.map(&:flatten) - [Array.new(@dimensions) { 0 }]
      end

      def point(*coords)
        GridPoint.new *coords
      end

      def get_status(point)
        @point_hash[point]
      end

      def set_status(point, active:)
        @point_hash[point] = active
      end

      def neighbors_of(point)
        directions.map { |direction| point.zip(direction).map(&:sum) }
      end

      def active_neighbor_count(point)
        neighbors_of(point).count(&method(:get_status))
      end

      def should_activate?(point)
        !get_status(point) && active_neighbor_count(point) == 3
      end

      def should_deactivate?(point)
        get_status(point) && !active_neighbor_count(point).between?(2, 3)
      end

      def activate!(point)
        set_status point, active: true
      end

      def deactivate!(point)
        set_status point, active: false
      end

      def points_to_consider
        @point_hash.keys.reduce(Set.new) do |set, point|
          set + [point, *neighbors_of(point)]
        end
      end

      def to_activate
        points_to_consider.select(&method(:should_activate?))
      end

      def to_deactivate
        points_to_consider.select(&method(:should_deactivate?))
      end

      def advance
        @to_activate = to_activate
        @to_deactivate = to_deactivate

        @to_activate.map(&method(:activate!))
        @to_deactivate.map(&method(:deactivate!))
      end

      def advance_by(number)
        number.times { advance }
        self
      end

      def active_cube_count
        @point_hash.count { |_point, status| status }
      end

      private

      def point_hash_from(char_array)
        point_hash = Hash.new
        char_array.map.with_index do |row, y|
          row.map.with_index do |char, x|
            point = [x, y, *(@dimensions - 2).times.map { 0 }]
            point_hash[point] = char == "#"
          end
        end
        point_hash
      end
    end
  end
end

