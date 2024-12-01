require "circle"
require "point"
require "solver"
require "vector"
require "range_monkeypatch"

module Year2022
  class Day15 < Solver
    def solve(part:)
      case part
      when 1 then horizontal_sensor_field.non_beacon_count
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

    def beacon_search
      BeaconSearchV2.new(sensors, distress_signal_range)
    end

    def distress_signal
      Vector.dot(beacon_search.beacon, [4000000, 1])
    end

    class BeaconSearch # ~60s
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

      def beacon
        @sensors.each.with_index do |sensor, index|
          puts "searching around sensor #{index} w/ radius=#{sensor.radius}"
          search_around(sensor).tap do |point|
            return point unless point.nil?
          end
        end
      end
    end

    class BeaconSearchV2 # ~90s, ~35s (reverse search)
      def initialize(sensors, limiting_value)
        @sensors = sensors
        @limiting_value = limiting_value
      end

      def beacon
        @beacon_point ||= (0..@limiting_value).each do |y_value|
          y_value = @limiting_value - y_value
          puts "searching at y = #{y_value}" if y_value % 100000 == 0
          HorizontalSensorField.new(
            @sensors,
            y_value,
            limiting_value: @limiting_value
          ).tap do |sensor_field|
            if sensor_field.ranges.size == 2
              x_value = sensor_field.ranges.map(&:max).min + 1
              return [x_value, y_value]
            end
          end
        end
      end
    end

    class HorizontalSensorField
      def initialize(sensors, y_value, limiting_value: nil)
        @sensors = sensors
        @y_value = y_value
        @limiting_value = limiting_value
      end

      def ranges
        @ranges ||= Range.union(
          @sensors.map { |sensor| sensor.circle.x_range(y_value: @y_value) }.compact
        )
      end

      def beacon_count
        @sensors.map(&:beacon).uniq.sum { |beacon| (beacon.last == @y_value) ? 1 : 0 }
      end

      def value_count
        @value_count ||= ranges.sum do |range|
          @limiting_value.nil? ?
            range.size :
            range.intersection(0..@limiting_value).size
        end
      end

      def non_beacon_count
        value_count - beacon_count
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
