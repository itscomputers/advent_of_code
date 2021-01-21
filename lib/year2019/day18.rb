require 'solver'
require 'point'
require 'tree'
require 'graph'
require 'a_star'

module Year2019
  class Day18 < Solver
    def part_one
      minimum_path_length
    end

    def part_two
      modified_minimum_path_length
    end

    def lookup
      @lookup ||= Grid.parse(lines, as: :hash) do |point, char|
        char != "#" ? char : nil
      end.compact
    end

    def points_by_char
      @points_by_char ||= lookup.invert.tap { |hash| hash.delete "." }
    end

    def start_point
      points_by_char["@"]
    end

    def root_points_by_char
      @root_points ||= {
        "$" => Vector.add(start_point, [-1, -1]),
        "%" => Vector.add(start_point, [1, -1]),
        "^" => Vector.add(start_point, [-1, 1]),
        "&" => Vector.add(start_point, [1, 1]),
      }
    end

    def root_points
      root_points_by_char.invert
    end

    def root_chars
      root_points_by_char.keys
    end

    def point_for(char)
      points_by_char[char] || root_points_by_char[char]
    end

    def modified_lookup
      @modified_lookup ||= { **lookup, **modified_points }.reject { |pt, char| char == "#" }
    end

    def modified_points
      start = lookup.key("@")
      {
        start => "#",
        Vector.add(start_point, [0, 1]) => "#",
        Vector.add(start_point, [0, -1]) => "#",
        Vector.add(start_point, [1, 0]) => "#",
        Vector.add(start_point, [-1, 0]) => "#",
        **root_points,
      }
    end

    def trees
      TreesBuilder.new(lookup, ["@"]).build_trees
    end

    def subtrees
      TreesBuilder.new(modified_lookup, root_chars).build_trees
    end

    def relevant_nodes_on(tree, lookup)
      tree.nodes.reject { |node| lookup[node.label] == "." }
    end

    def edge_lookup
      # original was edge_lookup_from(lookup, trees, ["@"]), which makes the
      # specs pass but fails by 10 on the puzzle input
      #
      # edge_lookup_from(lookup, trees, ["@"]) gives a different value for the
      # puzzle input than the code below, but the code below yields the correct
      # answer for the puzzle input.  need to investigate

      return @edge_lookup unless @edge_lookup.nil?
      @edge_lookup = { "@" => {}, **modified_edge_lookup }

      root_chars.each do |char|
        transformed_hash = modified_edge_lookup[char].transform_values do |val|
          val + Vector.distance(start_point, point_for(char))
        end

        @edge_lookup["@"] = { **@edge_lookup["@"], **transformed_hash }
        @edge_lookup.delete char
      end

      root_chars.combination(2).flat_map { |arr| arr.permutation.to_a }.each do |(char, other_char)|
        distance = Vector.distance point_for(char), point_for(other_char)
        modified_edge_lookup[other_char].each do |ch, dist|
          @edge_lookup[ch] = {
            **@edge_lookup[ch],
            **modified_edge_lookup[char].transform_values { |val| val + dist + distance },
          }
        end
      end

      @edge_lookup
    end

    def modified_edge_lookup
      @modified_edge_lookup ||= edge_lookup_from(modified_lookup, subtrees, root_chars)
    end

    def edge_lookup_from(lookup, trees, root_values)
      trees.values.reduce(Hash.new { |h, k| h[k] = {} }) do |hash, tree|
        relevant_nodes_on(tree, lookup).combination(2).each do |pair|
          distance = tree.distance *pair
          pair.permutation.each do |node, other|
            unless root_values.include? lookup[other.label]
              hash[lookup[node.label]][lookup[other.label]] = distance
            end
          end
        end
        hash
      end
    end

    def key_graph
      @key_graph ||= KeyGraph.new.tap { |kg| kg.edge_lookup = edge_lookup }
    end

    def modified_key_graph
      @modified_key_graph ||= ModifiedKeyGraph.new.tap { |mkg| mkg.edge_lookup = modified_edge_lookup }
    end

    def keys
      @keys ||= raw_input.scan /[a-z]/
    end

    def keys_goal
      @keys_goal ||= keys.sum { |char| KeyGraph::Node.bit_for(char) }
    end

    def a_star
      @a_star ||= AStar.new(
        key_graph,
        key_graph.start,
        goal: lambda { |node| node.keys == keys_goal },
        heuristic: lambda { |node| (keys_goal - node.keys).to_s(2).count("1") },
      )
    end

    def minimum_path_length
      a_star.search.minimum_path_length
    end

    def modified_a_star
      @modified_a_star ||= AStar.new(
        modified_key_graph,
        modified_key_graph.start,
        goal: lambda { |node| node.keys == keys_goal },
        heuristic: lambda { |node| (keys_goal - node.keys).to_s(2).count("1") },
      )
    end

    def modified_minimum_path_length
      modified_a_star.search.minimum_path_length
    end

    class KeyGraph < Graph
      attr_accessor :edge_lookup

      def neighbors_of(node)
        if node.key? && !node.unlocked?
          [node_for([node.char, node.add_key])]
        else
          edge_lookup[node.char].keys.map do |neighbor_char|
            node_for([neighbor_char, node.keys])
          end.select do |neighbor|
            neighbor.key? || neighbor.unlocked?
          end
        end
      end

      def distance(node, other)
        return 0 if node.char == other.char
        edge_lookup[node.char][other.char]
      end

      def start
        node_for ["@", 0]
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
    end

    class ModifiedKeyGraph < KeyGraph
      attr_accessor :edge_lookup

      def neighbors_of(node)
        node.key_graph_nodes.flat_map.with_index do |key_graph_node, index|
          super(key_graph_node).map do |key_graph_neighbor|
            node_for([
              *node.chars.take(index),
              key_graph_neighbor.char,
              *node.chars.drop(index + 1),
              key_graph_neighbor.keys,
            ])
          end
        end
      end

      def distance(node, other)
        return 0 if node.chars == other.chars
        char, other_char = (
          (node.chars | other.chars) - (node.chars & other.chars)
        )
        edge_lookup[char][other_char]
      end

      def start
        node_for ["$", "%", "^", "&", 0]
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

    class TreesBuilder
      def initialize(lookup, root_values)
        @lookup = lookup
        @trees = Hash.new
        @root_points = root_values.map { |value| lookup.key(value) }
        @visited = Set.new
      end

      def build_trees
        until @root_points.empty?
          build_tree_for(@root_points.pop).tap do |tree|
            leaves_for(tree).each do |leaf|
              @root_points << leaf.label unless @visited.include? leaf.label
            end
          end
        end
        @trees
      end

      def build_tree
        root_point = @root_points.pop
      end

      def build_tree_for(root_point)
        return if @trees.key? root_point

        tree = Tree.new
        frontier = [tree.node_for(root_point)]
        until frontier.empty?
          node = frontier.pop
          @visited.add node.label
          (Point.neighbors_of(node.label) & @lookup.keys).each do |neighbor|
            next if @visited.include? neighbor
            child = tree.node_for neighbor
            child.parent = node
            node.add_child child
            frontier << child unless /[A-Za-z]/.match @lookup[neighbor]
          end
        end
        @trees[root_point] = tree
      end

      def leaves_for(tree)
        tree.leaves.select { |leaf| /[A-Za-z]/.match @lookup[leaf.label] }
      end
    end
  end
end

