require "circle"
require "point"
require "solver"
require "set"
require "vector"

module Year2022
  class Day15 < Solver
    def solve(part:)
      case part
      when 1 then horizontal_sensor_field.non_beacon_values.size
      when 2 then distress_signal
      end
    end

    def sensors
      @sensors ||= lines.map { |line| Sensor.build(line) }
    end

    def y_value
      2000000
    end

    def distress_signal_range
      4000000
    end

    def horizontal_sensor_field
      HorizontalSensorField.new(sensors, y_value)
    end

    def beacon_point
      BeaconSearch.new(sensors, distress_signal_range).search
    end

    def distress_signal
      Vector.dot(beacon_point, [4000000, 1])
    end

    class BeaconSearch
      def initialize(sensors, range)
        @sensors = sensors
        @range = range
        @visited = Set.new
      end

      def search_around(sensor)
        sensor.circle.horizon_points.find do |point|
          next if @visited.include?(point)
          @visited.add(point)
          next unless point.all? { |coord| coord.between?(0, @range) }
          !@sensors.any? { |sensor| sensor.circle.include?(point) }
        end
      end

      def search
        @sensors.each do |sensor|
          puts "sensor: #{sensor.circle.center}, #{sensor.circle.radius}"
          search_around(sensor).tap do |point|
            return point unless point.nil?
          end
        end
      end
    end

    class HorizontalSensorField
      def initialize(sensors, y_value)
        @sensors = sensors
        @y_value = y_value
      end

      def values
        @sensors.reduce(Set.new) do |set, sensor|
          range = sensor.circle.x_range(y_value: @y_value)
          range.nil? ? set : set | range.to_a
        end
      end

      def beacon_values
        @sensors
          .map(&:beacon)
          .select { |beacon| beacon.last == @y_value }
          .map(&:first)
      end

      def non_beacon_values
        (values - beacon_values)
      end
    end

    class Sensor
      def self.build(line)
        Builder.new(line).build
      end

      attr_reader :beacon

      def initialize(location, beacon)
        @location = location
        @beacon = beacon
      end

      def circle
        @circle ||= Circle.new(@location, radius)
      end

      def radius
        @radius ||= Point.distance(@location, @beacon)
      end

      class Builder
        def initialize(line)
          @line = line
        end

        def build
          Sensor.new(sensor_location, beacon_location)
        end

        def sensor_location
          extract_coordinates(@line.match(/Sensor at x=(?<x>[-]?\d+), y=(?<y>[-]?\d+)/))
        end

        def beacon_location
          extract_coordinates(@line.match(/beacon is at x=(?<x>[-]?\d+), y=(?<y>[-]?\d+)/))
        end

        def extract_coordinates(match)
          [:x, :y].map { |key| match[key].to_i }
        end
      end
    end
  end
end
