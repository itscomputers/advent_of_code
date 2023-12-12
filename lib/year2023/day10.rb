require "solver"
require "grid"
require "point"
require "vector"
require "algorithms/bfs"

module Year2023
  class Day10 < Solver
    def solve(part:)
      case part
      when 1 then bfs.distances.values.max
      when 2 then interior_counter.count
      else nil
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash)
    end

    def graph
      @graph ||= Graph.build(grid)
    end

    def bfs
      @bfs ||= Algorithms::BFS.new(graph, source: graph.start).search
    end

    def start_directions
      graph
        .neighbors(graph.start)
        .map { |p| Vector.subtract(p, graph.start) }
    end

    def start_char
      case start_directions.sort
        when [[0, 1], [1, 0]] then "F"
        when [[0, -1], [0, 1]] then "|"
        when [[0, -1], [1, 0]] then "L"
        when [[-1, 0], [1, 0]] then "-"
        when [[-1, 0], [0, 1]] then "7"
        when [[-1, 0], [0, -1]] then "J"
        else "."
      end
    end

    def interior_counter
      @interior_counter ||= InteriorCounter.new(
        {**grid, graph.start => start_char},
        bfs.distances.keys,
      )
    end

    class Graph
      attr_accessor :start

      def self.build(grid)
        Builder.new(grid).build!
      end

      def initialize
        @lookup = Hash.new { |h, k| h[k] = Set.new }
      end

      def add_edge(source, destination)
        @lookup[source].add(destination)
      end

      def neighbors(point)
        @lookup[point]
      end

      def distance(source, target)
        neighbors(source).include?(target) ? 1 : nil
      end

      class Builder
        def initialize(grid)
          @grid = grid
          @graph = Graph.new
          @x_range = Grid.x_range(@grid.keys)
          @y_range = Grid.y_range(@grid.keys)
        end

        def build!
          @grid.keys.each(&method(:process))
          @graph
        end

        def process(point)
          @graph.start = point if @grid[point] == "S"
          get_neighbors(point).each do |neighbor|
            @graph.add_edge(point, neighbor) if in_range?(neighbor)
            @graph.add_edge(neighbor, point) if @grid[neighbor] == "S"
          end
        end

        def in_range?(neighbor)
          @x_range.include?(neighbor.first) && @y_range.include?(neighbor.last)
        end

        def get_neighbors(point)
          case @grid[point]
          when "|" then neighbors(point, [0, -1], [0, 1])
          when "-" then neighbors(point, [-1, 0], [1, 0])
          when "L" then neighbors(point, [0, -1], [1, 0])
          when "J" then neighbors(point, [0, -1], [-1, 0])
          when "7" then neighbors(point, [0, 1], [-1, 0])
          when "F" then neighbors(point, [0, 1], [1, 0])
          else []
          end
        end

        def neighbors(point, *directions)
          directions.map { |direction| Vector.add(point, direction) }
        end
      end
    end

    class InteriorCounter
      def initialize(grid, path_points)
        @grid = grid
        @path_points = Set.new(path_points)
        @x_max = Grid.x_range(grid.keys).max
        @points = grid.keys.reject { |point| @path_points.include?(point) }
      end

      def ray(point)
        (point.first..@x_max).map { |x| [x, point.last] }
      end

      def interior?(point)
        string_for(point).count("|").odd?
      end

      def string_for(point)
        ray(point)
          .select { |p| @path_points.include?(p) }
          .map { |p| @grid[p] }
          .join
          .gsub(/F-*J/, "|")
          .gsub(/F-*7/, "")
          .gsub(/L-*J/, "")
          .gsub(/L-*7/, "|")
      end

      def count
        @points.count(&method(:interior?))
      end
    end
  end
end
