require "point"
require "solver"

module Year2022
  class Day14 < Solver
    def solve(part:)
      cave(part: part).fill!.sand_count
    end

    def paths
      @paths ||= lines.map { |line| Path.build(line) }
    end

    def cave(part: 1)
      case part
      when 1 then Cave.new(paths)
      when 2 then CaveWithFloor.new(paths)
      end
    end

    class Cave
      attr_reader :sand_count

      def initialize(paths)
        @paths = paths
        @sand_count = 0
      end

      def points_lookup
        @points_lookup ||= @paths.reduce(Hash.new) do |hash, path|
          path.points.each do |point|
            add_point(point, lookup: hash)
          end
          hash
        end
      end

      def add_point(point, lookup: points_lookup)
        lookup[point.first] = [*lookup[point.first], point.last].sort.uniq
      end

      def point?(x, y)
        !!points_lookup.dig(x)&.include?(y)
      end

      def rock_y(sx, sy)
        return nil unless points_lookup.key?(sx)
        points_lookup[sx].drop_while { |y| y < sy }.first
      end

      def landing(sx, sy)
        ry = rock_y(sx, sy)
        return default_landing(sx) if ry.nil?
        return landing(sx - 1, ry) unless point?(sx - 1, ry)
        return landing(sx + 1, ry) unless point?(sx + 1, ry)
        [sx, ry - 1]
      end

      def default_landing(sx)
        nil
      end

      def fill!
        while sand_point = landing(500, 0)
          add_point(sand_point)
          @sand_count += 1
          break if sand_point == [500, 0]
        end
        self
      end
    end

    class CaveWithFloor < Cave
      def floor_y
        @floor_y ||= points_lookup.values.map(&:last).max + 2
      end

      def default_landing(sx)
        [sx, floor_y - 1]
      end

      def point?(x, y)
        super(x, y) || y == floor_y
      end
    end

    class Path
      def self.build(line)
        self.new(line.scan(/\d+,\d+/).map { |pair| pair.split(",").map(&:to_i) })
      end

      def initialize(pivots)
        @pivots = pivots
      end

      def points
        @points ||= @pivots.each_cons(2).flat_map(&method(:points_between)).uniq
      end

      def points_between(pair)
        xmin, xmax = pair.map(&:first).sort
        ymin, ymax = pair.map(&:last).sort
        (xmin..xmax).flat_map { |x| (ymin..ymax).map { |y| [x, y] } }
      end
    end
  end
end
