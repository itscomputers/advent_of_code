require "a_star"
require "graph"
require "grid"
require "point"
require "set"
require "solver"
require "vector"

module Year2022
  class Day24 < Solver
    def solve(part:)
      case part
      when 1 then blizzard_graph.initial_trip
      when 2 then blizzard_graph.final_trip
      end
    end

    def grid
      @grid ||= Grid.parse(lines, as: :hash)
    end

    def valley
      @valley ||= Valley.build(grid)
    end

    def start
      grid.find { |point, char| point.last == 0 && char == "." }.first
    end

    def goal
      grid.find { |point, char| point.last == valley.bottom && char == "." }.first
    end

    def blizzards
      grid.reduce(Set.new) do |set, (point, char)|
        set.add(Blizzard.build(point, char)) unless %w(# .).include?(char)
        set
      end
    end

    def blizzard_graph
       BlizzardGraph.new(valley, start, goal, blizzards)
    end

    class BlizzardGraph < BaseGraph
      def initialize(valley, start, goal, blizzards)
        @valley = valley
        @start = start
        @goal = goal
        @blizzards = blizzards
      end

      def neighbors(node)
        [node.point, *Point.neighbors_of(node.point)]
          .select { |point| [@start, @goal].include?(point) || @valley.include?(point) }
          .reject { |point| blizzard_positions(node.minute).include?(point) }
          .map { |point| Node.new(point, node.minute + 1) }
      end

      def distance(node, neighbor)
        Point.distance(node.point, neighbor.point)
      end

      def blizzard_positions(minute)
        @blizzard_positions ||= Hash.new
        @blizzard_positions[minute] ||= @blizzards.map do |blizzard|
          case blizzard.coord_index
          when 0 then blizzard.position_at(minute, @valley.x_range)
          when 1 then blizzard.position_at(minute, @valley.y_range)
          end
        end
      end

      def trip(start, goal, minute)
        AStar.new(Node.new(start, minute), goal, graph: self).execute.minute
      end

      def initial_trip
        @initial_trip ||= trip(@start, @goal, 1)
      end

      def return_trip
        trip(@goal, @start, initial_trip)
      end

      def final_trip
        trip(@start, @goal, return_trip)
      end

      class Node < Struct.new(:point, :minute)
      end

      class AStar < AStarGraph
        def finished?
          @goal == @path_node.node.point
        end

        def heuristic(node)
          node.minute + Point.distance(node.point, @goal)
        end

        def minute
          @path_node.node.minute - 1
        end
      end
    end

    class Valley < Struct.new(:x_range, :y_range)
      def self.build(grid)
        x_min, x_max = Grid.x_range(grid.keys).minmax
        y_min, y_max = Grid.y_range(grid.keys).minmax
        new(
          (x_min + 1...x_max),
          (y_min + 1...y_max),
        )
      end

      def bottom
        y_range.max + 1
      end

      def include?(point)
        [x_range, y_range].zip(point).all? { |(range, coord)| range === coord }
      end
    end

    class Blizzard < Struct.new(:position, :direction)
      def self.build(point, char)
        new(
          point,
          {">" => [1, 0], "v" => [0, 1], "<" => [-1, 0], "^" => [0, -1]}[char],
        )
      end

      def coord_index
        @coord_index ||= direction.index { |coord| coord != 0 }
      end

      def position_at(minute, range)
        Vector.add(position, Vector.scale(direction, minute)).map.with_index do |coord, index|
          coord_index == index ? ((coord - 1) % range.max) + 1 : coord
        end
      end
    end
  end
end
