require "solver"

module Year2023
  class Day13 < Solver
    def solve(part:)
      case part
      when 1 then summary(:mirror_image?)
      when 2 then summary(:smudge_mirror_image?)
      else nil
      end
    end

    def detect(chunk, method)
      value = Partition::Horizontal.detect(chunk, method)
      value *= 100 unless value.nil?
      value = Partition::Vertical.detect(chunk, method) if value.nil?
      value
    end

    def summary(method)
      chunks.map { |chunk| detect(chunk, method) }.sum
    end

    class Partition
      def self.detect(chunk, method)
        max = get_max(chunk)
        value = (0...max).find do |divider|
          new(points(chunk), divider, max).send(method)
        end
        value.nil? ? nil : value + 1
      end

      def self.get_max(chunk)
        raise NotImplementedError
      end

      def self.points(chunk)
        Grid.parse(chunk.split("\n"), as: :set) { "#" }
      end

      def initialize(points, divider, max)
        @points = points
        @divider = divider
        @max = max
      end

      def size
        [@max - @divider, @divider + 1].min
      end

      def value(point)
        raise NotImplementedError
      end

      def lower_point(point)
        raise NotImplementedError
      end

      def upper_point(point)
        raise NotImplementedError
      end

      def lower
        @lower ||= Set.new(
          @points
            .select { |point| value(point).between?(@divider - size + 1, @divider) }
            .map { |point| lower_point(point) }
        )
      end

      def upper
        @upper ||= Set.new(
          @points
            .select { |point| value(point).between?(@divider + 1, @divider + size) }
            .map { |point| upper_point(point) }
        )
      end

      def mirror_image?
        lower == upper
      end

      def smudges
        lower ^ upper
      end

      def smudge_mirror_image?
        smudges.size == 1
      end

      class Vertical < Partition
        def self.get_max(chunk)
          chunk.split("\n").first.length - 1
        end

        def value(point)
          point.first
        end

        def lower_point(point)
          [@divider - point.first, point.last]
        end

        def upper_point(point)
          [point.first - @divider - 1, point.last]
        end
      end

      class Horizontal < Partition
        def self.get_max(chunk)
          chunk.split("\n").size - 1
        end

        def value(point)
          point.last
        end

        def lower_point(point)
          [point.first, @divider - point.last]
        end

        def upper_point(point)
          [point.first, point.last - @divider - 1]
        end
      end
    end
  end
end
