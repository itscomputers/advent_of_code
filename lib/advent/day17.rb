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

      def get_status(point)
        @point_hash[point]
      end

      def set_status(point, active:)
        @point_hash[point] = active
      end

      def neighbors_of(point)
        directions.map { |direction| point.zip(direction).map(&:sum) }
      end

      def active_count(points)
        points.count(&method(:get_status))
      end

      def action(status, count)
        if !status && count == 3
          :activate!
        elsif status && !count.between?(2, 3)
          :deactivate!
        end
      end

      def activation_data
        boundary = Set.new

        result = @point_hash.each_with_object(Hash.new) do |(point, status), memo|
          neighbors = neighbors_of(point).tap do |neighbors|
            neighbors.each { |nb| boundary.add(nb) unless @point_hash.key? nb }
          end

          memo[point] = action status, active_count(neighbors)
        end

        boundary.each do |point|
          result[point] = action get_status(point), active_count(neighbors_of point)
        end

        result
      end

      def activate!(point)
        @point_hash[point] = true
      end

      def deactivate!(point)
        @point_hash.delete point
      end

      def advance
        activation_data.each do |point, action|
          send action, point unless action.nil?
        end
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
            point_hash[point] = true if char == "#"
          end
        end
        point_hash
      end
    end
  end
end

