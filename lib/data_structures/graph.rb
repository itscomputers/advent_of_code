module DataStructures
  class Graph
    def initialize
      @lookup = Hash.new
    end

    def add_node(key)
      @lookup[key] ||= Hash.new
    end

    def has_node?(key)
      @lookup.key?(key)
    end

    def add_edge(source, target, weight: 1)
      add_node(source)
      add_node(target)
      @lookup[source][target] = weight
    end

    def remove_edge(source, target)
      edge_lookup(source).delete(target)
      edge_lookup.delete(source) if edge_lookup(source).empty?
    end

    def distance(source, target)
      edge_lookup(source).dig(target)
    end

    def neighbors(key)
      edge_lookup(key).keys
    end

    def adjacent?(source, target)
      !distance(source, target).nil?
    end

    def nearest_neighbor(key)
      edge_lookup(key).min_by { |_k, v| v }&.first
    end

    private

    def edge_lookup(key)
      @lookup[key] || Hash.new
    end
  end
end
