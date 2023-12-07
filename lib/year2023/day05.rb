require "solver"
require "range_monkeypatch"

module Year2023
  class Day05 < Solver
    def solve(part:)
      case part
      when 1 then locations.min
      when 2 then location_ranges.map(&:min).min
      else nil
      end
    end

    def seeds
      @seeds ||= lines.first&.split(": ").last&.split(" ").map(&:to_i)
    end

    def seed_ranges
      seeds.each_slice(2).map { |(start, len)| (start..start+len-1) }
    end

    def locations
      maps.reduce(seeds) do |numbers, map|
        map.get(numbers)
      end
    end

    def location_ranges
      maps.reduce(seed_ranges) do |ranges, map|
        map.get_ranges(ranges)
      end
    end

    def maps
      @maps ||= chunks.drop(1).map { |chunk| Map.build(chunk) }
    end

    class Map
      attr_reader :source, :destination

      def self.build(chunk)
        new(
          *chunk.split("\n").first.split(" ").first.split("-to-"),
          chunk.split("\n").drop(1)
        )
      end

      def initialize(source, destination, lines)
        @source = source
        @destination = destination
        @mappings = lines.map { |line| Mapping.build(line) }
      end

      def get(numbers)
        numbers.map do |number|
          mapping = @mappings.find { |mapping| mapping.has?(number) }
          mapping.nil? ? number : mapping.get(number)
        end
      end

      def get_ranges(ranges)
        @mappings.reduce({ mapped: [], unmapped: ranges }) do |data, mapping|
          data[:unmapped].reduce({**data, unmapped: []}) do |result, range|
            update(result, mapping, range)
          end
        end.values.flatten
      end

      def update(data, mapping, range)
        if mapping.has_range?(range)
          mapped, unmapped = mapping.get_ranges(range).slice(:mapped, :unmapped).values
          data[:mapped] << mapped
          data[:unmapped] += unmapped
        else
          data[:unmapped] << range
        end
        data
      end

      class Mapping < Struct.new(:dst, :src, :len)
        def self.build(line)
          new(*line.split(" ").map(&:to_i))
        end

        def range
          @range ||= (src..src + len - 1)
        end

        def has?(number)
          range.include?(number)
        end

        def get(number)
          dst + number - src
        end

        def has_range?(other)
          range.overlap?(other)
        end

        def get_ranges(other)
          lower, upper = other.intersection(range).minmax
          {
            mapped: (dst - src + lower .. dst - src + upper),
            unmapped: other.subtract(range),
          }
        end
      end
    end
  end
end
