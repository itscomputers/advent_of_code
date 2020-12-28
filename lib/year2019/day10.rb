require 'solver'
require 'vector'

module Year2019
  class Day10 < Solver
    def part_one
      monitoring_station.visible_asteroid_count
    end

    def part_two
      Vector.dot monitoring_station.nth_vaporized(vaporization_count), [100, 1]
    end

    def vaporization_count
      200
    end

    def asteroids
      @asteroids ||= grid_parser.parse_as_set char: "#"
    end

    def monitoring_station
      @monitoring_station ||= asteroids.map do |asteroid|
        AsteroidMonitoringStation.new asteroid, asteroids
      end.max_by do |station|
        station.visible_asteroid_count
      end
    end

    class AsteroidMonitoringStation
      def initialize(location, asteroids)
        @location = location
        @asteroids = asteroids - [location]
        @vaporized_count = 0
        @last_vaporized = nil
      end

      def slope_to(asteroid)
        Vector.subtract asteroid, @location
      end

      def reduced_slope_to(asteroid)
        slope = slope_to asteroid
        slope.map { |val| val / slope.reduce(&:gcd) }
      end

      def distance_to(asteroid)
        slope_to(asteroid).sum(&:abs)
      end

      def group_by_reduced_slope
        @group_by_reduced_slope ||= @asteroids
          .group_by(&method(:reduced_slope_to))
          .transform_values { |group| group.sort_by(&method(:distance_to)) }
      end

      def visible_asteroid_count
        group_by_reduced_slope.size
      end

      def ordered_reduced_slopes
        @ordered_reduced_slopes ||= group_by_reduced_slope.keys.sort_by do |slope|
          [
            slope == [0, -1] && 0 || 1,
            slope.first > 0 && 0 || 1,
            slope == [0, 1] && 0 || 1,
            slope.reverse.map(&:to_f).reduce(:/),
          ]
        end.cycle
      end

      def slope
        ordered_reduced_slopes.next
      end

      def group
        @group = group_by_reduced_slope[slope]
      end

      def vaporize!
        unless group.empty?
          @last_vaporized = @group.shift
          @vaporized_count += 1
        end
        @group
      end

      def nth_vaporized(number)
        vaporize! until @vaporized_count >= number
        raise "already surpassed #{number}" if @vaporized_count > number
        @last_vaporized
      end
    end
  end
end

