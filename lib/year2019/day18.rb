require 'solver'
require 'point'
require 'tree'
require 'graph'
require 'a_star'

module Year2019
  class Day18 < Solver
    def solve(part:)
      key_graph(part: part).a_star.execute.min_path_cost
    end

    def symbol_lookup
      @symbol_lookup ||= Grid.parse(lines, as: :hash) do |point, char|
        case char
        when "#" then nil
        when "." then point.to_a.join(",")
        else char
        end
      end.compact
    end

    def modified_lookup
      start_point = symbol_lookup.invert.dig("@")
      root_points = {
        Vector.add(start_point, [-1, -1]) => "$",
        Vector.add(start_point, [1, -1]) => "%",
        Vector.add(start_point, [-1, 1]) => "^",
        Vector.add(start_point, [1, 1]) => "&",
      }
      deleted_points = [
        Vector.add(start_point, [0, 1]),
        Vector.add(start_point, [0, -1]),
        Vector.add(start_point, [1, 0]),
        Vector.add(start_point, [-1, 0]),
      ]
      {**symbol_lookup, **root_points }.reject do |point, _|
        deleted_points.include?(point)
      end
    end

    def graph
      GraphBuilder.new(symbol_lookup).reduce!.graph
    end

    def modified_graph
      GraphBuilder.new(modified_lookup).reduce!.graph
    end

    def key_graph(part:)
      case part
      when 1 then KeyGraph.new(graph)
      when 2 then ModifiedKeyGraph.new(modified_graph)
      end
    end

    class GraphBuilder
      def initialize(symbol_lookup)
        @symbol_lookup = symbol_lookup
      end

      def graph
        @graph ||= Graph::SimpleDirectedGraphBuilder.new(
          @symbol_lookup.reduce(Hash.new) do |hash, (point, char)|
            hash[char] = Point.neighbors_of(point).map do |neighbor_point|
              @symbol_lookup.dig(neighbor_point)
            end.compact
            hash
          end,
        ).build
      end

      def reduce!
        graph.node_lookup.delete_if do |key, _|
          key.match(/\d+,\d+/)
        end
        graph.node_lookup.values.each do |node|
          EdgeReducer.new(node).reduce
        end
        self
      end
    end

    class EdgeReducer
      def initialize(node)
        @node = node
        @visited = Set.new([node])
        @edges = Hash.new
        @frontier = node.edges.values
      end

      def advance
        edge = @frontier.shift
        @visited.add(edge.target)

        unless edge.target.value.match(/\d+,\d+/)
          @edges[edge.target.value] = edge
          return
        end

        edge.target.edges.values
          .reject { |neighbor_edge| @visited.include?(neighbor_edge.target) }
          .each do |neighbor_edge|
            new_edge = Graph::Edge.new(
              @node,
              neighbor_edge.target,
              edge.weight + neighbor_edge.weight,
            )
            @frontier << new_edge
          end
        self
      end

      def reduce
        advance until @frontier.empty?
        @node.edges = @edges
        @node
      end
    end

    class KeyGraph < Graph
      def initialize(graph)
        @graph = graph
        @node_lookup = Hash.new
      end

      def neighbors(key_node)
        if key_node.key? && !key_node.unlocked?
          [node([key_node.char, key_node.add_key])]
        else
          @graph.node(key_node.char).neighbors.map do |neighbor|
            node([neighbor.value, key_node.keys])
          end.select do |key_neighbor|
            key_neighbor.key? || key_neighbor.unlocked?
          end
        end
      end

      def distance(key_node, other)
        return 0 if key_node.char == other.char
        @graph.distance(key_node.char, other.char)
      end

      def shortest_distance(key_node)
        @graph.shortest_distance(key_node.char)
      end

      def start
        node(["@", 0])
      end

      def keys
        @graph.nodes.map(&:value).join.scan(/[a-z]/)
      end

      def a_star
        @a_star ||= AStar.new(self)
      end

      class Node < Graph::Node
        def self.bit_for(char)
          @bitmap ||= Hash.new
          @bitmap[char] ||= 1 << (char.downcase.ord - 'a'.ord)
        end

        def char
          value.first
        end

        def keys
          value.last
        end

        def inspect
          "<#{char}, keys=#{keys}>"
        end

        def bit
          self.class.bit_for char
        end

        def key?
          !!/[a-z]/.match(char)
        end

        def door?
          !!/[A-Z]/.match(char)
        end

        def unlocked?
          keys == keys | bit
        end

        def add_key
          !key? || unlocked? ? keys : keys ^ bit
        end
      end

      class AStar < AStarGraph
        def initialize(key_graph)
          super(key_graph.start, "", graph: key_graph)
        end

        def keys_goal
          @keys_goal ||= @graph.keys.sum { |char| Node.bit_for(char) }
        end

        def heuristic(key_node)
          (keys_goal - key_node.keys).to_s(2).count("1")
        end

        def finished?
          @path_node.node.keys == keys_goal
        end
      end
    end

    class ModifiedKeyGraph < KeyGraph
      def neighbors(key_node)
        key_node.key_graph_nodes.flat_map.with_index do |key_graph_node, index|
          super(key_graph_node).map do |key_graph_neighbor|
            node([
              *key_node.chars.take(index),
              key_graph_neighbor.char,
              *key_node.chars.drop(index + 1),
              key_graph_neighbor.keys,
            ])
          end
        end
      end

      def distance(key_node, other)
        return 0 if key_node.chars == other.chars
        @graph.distance(*(
          (key_node.chars | other.chars) - (key_node.chars & other.chars)
        ))
      end

      def shortest_distance(key_node)
        key_node.chars.map do |char|
          @graph.shortest_distance(char)
        end.min
      end

      def start
        node(["$", "%", "^", "&", 0])
      end

      class Node < KeyGraph::Node
        def chars
          value.take(4)
        end

        def key_graph_nodes
          chars.map { |char| KeyGraph::Node.new([char, keys]) }
        end

        def inspect
          "<#{chars}, keys=#{keys}>"
        end
      end
    end
  end
end

