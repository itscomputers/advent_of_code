class BaseGraph
  def neighbors(value)
    raise NotImplementedError
  end

  def distance(value, neighbor)
    raise NotImplementedError
  end

  class Builder
    def initialize(inputs, graph:)
      @inputs = inputs
      @graph = graph
    end

    def build
      @inputs.each(&method(:process))
      @graph
    end

    def process(input)
      raise NotImplementedError
    end
  end
end

class Graph
  attr_reader :node_lookup

  def initialize
    @node_lookup = Hash.new
  end

  def inspect
    "<Graph node_count=#{nodes.size}>"
  end

  def nodes
    @node_lookup.values
  end

  def node(value)
    @node_lookup[value] ||= self.class::Node.new(value)
  end

  def neighbors(value)
    node(value).neighbors.map(&:value)
  end

  def distance(value, other)
    node(value).weight(node(other))
  end

  def closest_neighbor(value)
    node(value).closest_neighbor.value
  end

  def shortest_distance(value)
    node(value).shortest_distance
  end

  def adjacent?(value, other)
    node(value).has_neighbor?(node(other))
  end

  def to_h
    @as_hash ||= nodes.reduce(Hash.new) do |hash, node|
      hash[node.value] = node.edges.reduce(Hash.new) do |inner_hash, (key, edge)|
        inner_hash[key] = edge.weight
        inner_hash
      end
      hash
    end
  end

  class Node < Struct.new(:value)
    def inspect
      "<Graph::Node #{value}>"
    end

    def edges
      @edges ||= Hash.new
    end

    def edges=(value)
      @edges = value
    end

    def add_edge(node, weight)
      edges[node.value] = Edge.new(self, node, weight)
    end

    def neighbors
      edges.values.map(&:target)
    end

    def has_neighbor?(other)
      edges.key?(other.value)
    end

    def weight(other)
      edges[other.value]&.weight
    end

    def min_edge
      @min_edge ||= edges.values.min_by(&:weight)
    end

    def shortest_distance
      min_edge&.weight
    end

    def closest_neighbor
      min_edge&.target
    end
  end

  class Edge < Struct.new(:source, :target, :weight)
    def inspect
      "<Graph::Edge #{source.value} --#{weight}--> #{target.value}>"
    end
    alias_method :to_s, :inspect
  end

  class DirectedGraphBuilder
    def initialize(hash, graph: nil)
      @hash = hash
      @graph = graph || Graph.new
    end

    def build
      @hash.keys.each do |key|
        node = @graph.node(key)
        neighbor_values(node).each do |neighbor_value|
          neighbor = @graph.node(neighbor_value)
          add_edges(node, neighbor)
        end
      end
      @graph
    end

    def neighbor_values(node)
      @hash.dig(node.value).keys
    end

    def weight(node, neighbor)
      @hash.dig(node.value)&.dig(neighbor.value)
    end

    def add_edges(node, neighbor)
      node.add_edge(neighbor, weight(node, neighbor))
    end
  end

  class UndirectedGraphBuilder < DirectedGraphBuilder
    def add_edges(node, neighbor)
      super
      neighbor.add_edge(node, weight(node, neighbor))
    end
  end

  class SimpleDirectedGraphBuilder < DirectedGraphBuilder
    def neighbor_values(node)
      @hash.dig(node.value)
    end

    def weight(node, neighbor)
      1
    end
  end

  class SimpleUndirectedGraphBuilder < UndirectedGraphBuilder
    def neighbor_values(node)
      @hash.dig(node.value)
    end

    def weight(node, neighbor)
      1
    end
  end
end

