require "solver"
require "vector"
require "range_monkeypatch"

module Year2023
  class Day22 < Solver
    def solve(part:)
      case part
      when 1 then configuration.removable_count
      when 2 then disintegrator.total_fall_count
      end
    end

    def configuration
      @configuration ||= Configuration.build(lines).resolve
    end

    def disintegrator
      Disintegrator.new(configuration)
    end

    class Disintegrator
      def initialize(configuration)
        @configuration = configuration
      end

      def configuration_without(brick)
        Configuration.new(bricks_without(brick))
      end

      def bricks_without(brick)
        @configuration.bricks.reject { |b| b == brick }.map(&:copy)
      end

      def fall_count(brick)
        configuration_without(brick).resolve.fall_count
      end

      def total_fall_count
        @configuration.bricks.reject(&:removable?).map(&method(:fall_count)).sum
      end
    end

    class Configuration
      attr_reader :bricks

      def self.build(lines)
        new(lines.map { |line| Brick.build(line) })
      end

      def initialize(bricks)
        @bricks = bricks.sort
      end

      def resolve
        @fall_count = @bricks.count(&method(:resolve_brick?))
        self
      end

      attr_reader :fall_count

      def resolve_brick?(brick)
        BrickResolver.new(brick, @bricks).resolve?
      end

      def removable_count
        @bricks.count(&:removable?)
      end

      class BrickResolver
        def initialize(brick, bricks)
          @brick = brick
          @bricks = bricks
          @value = nil
          @lower_bricks = []
        end

        def bricks
          @bricks.select { |brick| @brick.above?(brick) }
        end

        def resolve?
          bricks.each do |brick|
            z_dist = @brick.z_distance(brick)
            if @value.nil? || z_dist < @value
              @lower_bricks = [brick]
              @value = z_dist
            elsif z_dist == @value
              @lower_bricks << brick
            end
          end
          set_brick_state
          @brick.moved
        end

        def set_brick_state
          if @value.nil?
            @brick.decrement_by(@brick.z_range.min - 1)
          else
            @brick.decrement_by(@value - 1)
            @brick.lower_bricks = @lower_bricks
            @lower_bricks.each do |brick|
              brick.upper_bricks << @brick
            end
          end
        end
      end
    end

    class Brick
      include Comparable

      attr_reader :x_range, :y_range, :z_range, :moved
      attr_accessor :lower_bricks, :upper_bricks

      def self.build(line)
        new(line.split("~").map { |coords| coords.split(",").map(&:to_i) })
      end

      def initialize(endpoints)
        @endpoints = endpoints
        @lower_bricks = []
        @upper_bricks = []
        set_ranges
        @moved = false
      end

      def copy
        Brick.new(@endpoints).tap do |brick|
          brick.lower_bricks = @lower_bricks
          brick.upper_bricks = @upper_bricks
          brick.set_ranges
        end
      end

      def inspect
        "<#{@endpoints}, l=#{@lower_bricks.size}, u=#{@upper_bricks.size}>"
      end
      alias_method :to_s, :inspect

      def set_ranges
        @x_range, @y_range, @z_range = (0..2).map do |index|
          Range.new(*@endpoints.map { |ep| ep[index] }.sort)
        end
      end

      def decrement_by(value)
        @moved = true if value > 0
        @endpoints = decrement(@endpoints, value)
        set_ranges
      end

      def decrement(pts, value)
        pts.map { |point| [*point.take(2), point.last - value] }
      end

      def above?(brick)
        z_distance(brick) > 0 &&
          !@x_range.intersection(brick.x_range).nil? &&
          !@y_range.intersection(brick.y_range).nil?
      end

      def z_distance(brick)
        @z_range.min - brick.z_range.max
      end

      def <=>(other)
        @z_range.min <=> other.z_range.min
      end

      def removable?
        upper_bricks.none? { |upper| upper.lower_bricks == [self] }
      end
    end
  end
end
