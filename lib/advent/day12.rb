require 'advent/day'
require 'util'

module Advent
  class Day12 < Advent::Day
    DAY = "12"

    EAST = Point.new 1, 0
    WEST = Point.new -1, 0
    NORTH = Point.new 0, 1
    SOUTH = Point.new 0, -1

    DIRECTION_DEGREE = {
      EAST => 0,
      NORTH => 90,
      WEST => 180,
      SOUTH => 270,
    }

    DEGREE_DIRECTION = DIRECTION_DEGREE.invert

    def self.sanitized_input
      raw_input.split("\n").map do |string|
        match = instruction_regex.match string
        [match[:action], match[:value]]
      end
    end

    def self.instruction_regex
      @instruction_regex ||= Regexp.new /(?<action>[NSEWLRF])(?<value>\d+)/
    end

    def initialize(input)
      @input = input
    end

    def solve(part:)
      case part
      when 1 then executor.execute_all.distance
      when 2 then enhanced_executor.execute_all.distance
      end
    end

    def executor
      Executor.new @input, Point.new(0, 0), EAST
    end

    def enhanced_executor
      EnhancedExecutor.new @input, Point.new(0, 0), EAST, Point.new(10, 1)
    end

    class Executor
      def initialize(input, location, direction)
        @instructions = input.map { |args| Instruction.new *args }
        @location = location
        @direction = direction
      end

      def inspect
        "<EnhancedExecutor #{to_h.map { |k, v| "@#{k}=#{v.inspect}" }.join(" ") }>"
      end

      def distance
        @location.x.abs + @location.y.abs
      end

      def execute_all
        execute_next while !@instructions.empty?
        self
      end

      def to_h
        { :location => @location, :direction => @direction }
      end

      def set_hash(hash)
        @location = hash[:location]
        @direction = hash[:direction]
      end

      def execute_next
        set_hash @instructions.shift.execute **to_h
      end

      class Instruction
        def initialize(action, value)
          @action = action
          @value = value.to_i
        end

        def execute(**options)
          case @action
          when "E" then move(primary_key, EAST, options)
          when "N" then move(primary_key, NORTH, options)
          when "W" then move(primary_key, WEST, options)
          when "S" then move(primary_key, SOUTH, options)
          when "L" then turn_clockwise(options)
          when "R" then turn_counter_clockwise(options)
          when "F" then forward(options)
          end
        end

        def move(key, direction, options)
          { **options, key => options[key] + direction * @value }
        end

        def turn(orientation, options)
          { **options, :direction => send(orientation, options) }
        end

        def turn_clockwise(options)
          { **options, :direction => clockwise(options) }
        end

        def turn_counter_clockwise(options)
          { **options, :direction => counter_clockwise(options) }
        end

        def forward(options)
          { **options, :location => options[:location] + options[:direction] * @value }
        end

        def primary_key
          :location
        end

        def clockwise(options)
          DEGREE_DIRECTION[(DIRECTION_DEGREE[options[:direction]] + @value) % 360]
        end

        def counter_clockwise(options)
          DEGREE_DIRECTION[(DIRECTION_DEGREE[options[:direction]] - @value) % 360]
        end
      end
    end

    class EnhancedExecutor < Executor
      def initialize(input, location, direction, waypoint)
        @instructions = input.map { |args| Instruction.new *args }
        @location = location
        @direction = direction
        @waypoint = waypoint
      end

      def to_h
        { **super, :waypoint => @waypoint }
      end

      def set_hash(hash)
        super
        @waypoint = hash[:waypoint]
      end

      class Instruction < Advent::Day12::Executor::Instruction
        def primary_key
          :waypoint
        end

        def turn(orientation, options)
          self.send "turn_#{orientation}", options
        end

        def turn_clockwise(options)
          x, y = options[:waypoint].to_a
          (@value / 90).times do
            x, y = -y, x
          end
          {
            **options,
            :waypoint => Point.new(x, y),
            :direction => clockwise(options)
          }
        end

        def turn_counter_clockwise(options)
          x, y = options[:waypoint].to_a
          (@value / 90).times do
            x, y = y, -x
          end
          {
            **options,
            :waypoint => Point.new(x, y),
            :direction => counter_clockwise(options)
          }
        end

        def forward(options)
          { **options, :location => options[:location] + options[:waypoint] * @value }
        end
      end
    end
  end
end

