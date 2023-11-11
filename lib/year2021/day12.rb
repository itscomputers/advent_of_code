require "solver"
require "set"
require "tree"

module Year2021
  class Day12 < Solver
    def solve(part:)
      case part
      when 1 then path_finder.path_count
      when 2 then permissive_path_finder.path_count
      end
    end

    def path_finder
      PathFinder.from_lines(lines)
    end

    def permissive_path_finder
      PathFinder.from_lines(lines, permissive: true)
    end

    class PathFinder
      def self.from_lines(lines, permissive: false)
        new(
          lines.reduce(Hash.new { |h, k| h[k] = [] }) do |hash, line|
            node, other = line.split("-")
            hash[node] << other
            hash[other] << node
            hash
          end,
          permissive: permissive,
        )
      end

      attr_reader :paths

      def initialize(edge_hash, permissive:)
        @edge_hash = edge_hash
        path_class = permissive ? PermissivePath : Path
        @paths = [path_class.new(["start"], @edge_hash)]
      end

      def inspect
        "<PathFinder #{@paths.map(&:inspect).join("; ")}>"
      end

      def to_s
        inspect
      end

      def advance
        terminal, open = @paths.partition(&:terminal?)
        @paths = [*terminal, *open.flat_map(&:branch_paths)]
        self
      end

      def path_count
        advance until @paths.all?(&:terminal?)
        @paths.count
      end

      class Path
        attr_reader :nodes, :visited, :small_cave

        def initialize(nodes, edge_hash, visited: Set.new, small_cave: nil)
          @nodes = nodes
          @edge_hash = edge_hash
          @visited = visited
          @small_cave = small_cave
        end

        def inspect
          "#{@nodes.join(",")}"
        end

        def to_s
          inspect
        end

        def terminal?
          @nodes.last == "end"
        end

        def frontier
          (@edge_hash[@nodes.last] || []).reject(&method(:invalid_node?))
        end

        def branch_paths
          frontier.map(&method(:branch_path)).compact
        end

        def small_cave(node)
          return @small_cave unless @small_cave.nil?
          return node if node.downcase? && @visited.include?(node)
          nil
        end

        def branch_path(node)
          self.class.new(
            [*@nodes, node],
            @edge_hash,
            visited: branch_visited(node),
            small_cave: small_cave(node),
          )
        end

        def branch_visited(node)
          add_to_visited?(node) ? @visited + [node] : @visited
        end

        def invalid_node?(node)
          node == "start" || (node.downcase? && @visited.include?(node))
        end

        def add_to_visited?(node)
          node.downcase?
        end
      end

      class PermissivePath < Path
        def invalid_node?(node)
          if node == "start"
            true
          elsif node.downcase? && @visited.include?(node)
            if @small_cave.nil?
              false
            else
              true
            end
          else
            false
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

