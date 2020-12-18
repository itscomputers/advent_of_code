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
        @active_points = active_points_from(char_array)
      end

      def directions
        @directions ||= (@dimensions - 1).times.reduce([-1, 0, 1]) do |array, _|
          [-1, 0, 1].product(array)
        end.map(&:flatten) - [Array.new(@dimensions) { 0 }]
      end

      def get_status(point)
        @active_points.include? point
      end

      def neighbors_of(point)
        directions.map { |direction| point.zip(direction).map(&:sum) }
      end

      def active_count(points)
        (@active_points & points).count
      end

      def action(status, count)
        if !status && count == 3
          :activate!
        elsif status && !count.between?(2, 3)
          :deactivate!
        end
      end

      def activation_data
        inactive_neighbors = Set.new

        result = @active_points.each_with_object(Hash.new) do |point, memo|
          neighbors = neighbors_of(point).tap do |neighbors|
            neighbors.each { |nb| inactive_neighbors.add(nb) unless get_status(nb) }
          end

          memo[point] = action true, active_count(neighbors)
        end

        inactive_neighbors.each do |point|
          result[point] = action false, active_count(neighbors_of point)
        end

        result
      end

      def activate!(point)
        @active_points.add point
      end

      def deactivate!(point)
        @active_points.delete point
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
        @active_points.count
      end

      private

      def active_points_from(char_array)
        char_array.each_with_index.reduce(Set.new) do |set, (row, y)|
          row.map.with_index do |char, x|
            next unless char == "#"
            set.add [x, y, *(@dimensions - 2).times.map { 0 }]
          end
          set
        end
      end
    end
  end
end

