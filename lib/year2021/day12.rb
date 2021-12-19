require "solver"
require "set"

module Year2021
  class Day12 < Solver
    def solve(part:)
      case part
      when 1 then cave_graph.paths.search.path_count
      when 2 then cave_graph.permissive_paths.search.path_count
      end
    end

    def cave_graph
      @cave_graph ||= CaveGraph.build_from(lines)
    end

    class CaveGraph
      REGEX = /([\w]+)-([\w]+)/

      def self.build_from(lines)
        new.tap do |graph|
          lines.each do |line|
            label, other_label = REGEX.match(line).to_a.drop(1)
            graph.node_for(label).add_child(graph.node_for(other_label))
            graph.node_for(other_label).add_child(graph.node_for(label))
          end
        end
      end

      def initialize
        @cave_lookup = Hash.new
      end

      def node_for(label)
        @cave_lookup[label] ||= Cave.new(label)
      end

      def caves
        @cave_lookup.values
      end

      def paths
        @paths ||= Paths.new(self, source: "start", target: "end", permissive: false)
      end

      def permissive_paths
        @permissive_paths ||= Paths.new(self, source: "start", target: "end", permissive: true)
      end

      class Cave
        attr_reader :label, :children

        def initialize(label)
          @label = label
          @children = Set.new
          @paths_lookup = {}
        end

        def inspect
          "<Cave #{@label} -> #{@children.map(&:label).join(", ")}>"
        end

        def add_child(cave)
          @children.add(cave)
        end
      end

      class Paths
        attr_reader :frontier, :terminal

        def initialize(graph, source:, target:, permissive:)
          @graph = graph
          @target = target

          path = permissive ?
            PermissivePath.new([source]) :
            Path.new([source])

          @frontier = [path]
          @terminal = Set.new([])
        end

        def inspect
          "<Paths frontier: #{@frontier.size}, terminal: #{@terminal.size}>"
        end

        def path_count
          @terminal.size
        end

        def search
          advance until @frontier.empty?
          self
        end

        def advance
          terminal, frontier = @frontier.partition(&:terminal?)
          frontier = frontier.flat_map do |path|
            @graph.node_for(path.last).children.map do |child|
              path.with?(child.label)
            end.compact
          end.uniq
          @frontier = frontier
          @terminal += terminal
          self
        end

        class Path
          attr_reader :array

          def initialize(array)
            @array = array
          end

          def last
            @array.last
          end

          def terminal?
            last == "end"
          end

          def with?(value)
            return if value == "start"
            return if duplicate?(value)
            Path.new([*@array, value])
          end

          def duplicate?(value)
            value.downcase? && @array.include?(value)
          end

          def eql?(other)
            @array == other.array
          end

          def ==(other)
            eql?(other)
          end

          def hash
            @array.hash
          end
        end

        class PermissivePath < Path
          def initialize(array)
            super(array)
            @can_visit_duplicate = true
          end

          def with?(value)
            return if value == "start"

            duplicate?(value).tap do |duplicate|
              return if duplicate && !@can_visit_duplicate
              @can_visit_duplicate = false if duplicate
            end

            PermissivePath.new([*@array, value])
          end
        end
      end
    end
  end
end

class String
  def downcase?
    self == downcase
  end
end
