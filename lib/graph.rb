class Graph
  def initialize
    @node_lookup = Hash.new
  end

  def inspect
    "<Graph node_count=#{nodes.size}>"
  end

  def nodes
    @node_lookup.values
  end

  def node_for(value)
    @node_lookup[value] ||= self.class::Node.new value
  end

  def neighbors_of(node)
    node.neighbors
  end

  def distance(node, other)
    raise unless neighbors_of(node).include? other
    node.weight_for other
  end

  class Node < Struct.new(:value)
    def inspect
      "<Graph::Node #{value}>"
    end

    def neighbors
      @neighbors ||= Hash.new
    end

    def add_neighbor(node, weight)
      neighbors[node] = weight
    end

    def has_neighbor?(node)
      neighbors.key? node
    end

    def weight_for(node)
      raise unless has_neighbor? node
      neighbors[node]
    end
  end

  class Builder
    def initialize(hash)
      @hash = hash
      @graph = Graph.new
    end

    def build
      @hash.each do |value, neighbor_values|
        node = @graph.node_for(value)
        if neighbor_values.is_a?(Hash)
          neighbor_values.each do |neighbor_value, weight|
            node.add_neighbor(@graph.node_for(neighbor_value), weight)
          end
        else
          neighbor_values.each do |neighbor_value|
            node.add_neighbor(@graph.node_for(neighbor_value), 1)
          end
        end
      end
      @graph
    end
  end
end

