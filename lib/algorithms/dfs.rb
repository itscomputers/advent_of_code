require "algorithms/graph_search"

module Algorithms
  class DFS < GraphSearch
    def self.get_path(graph, source, target)
      new(graph, source: source, target: target).search.get_path
    end

    def self.get_distance(graph, source, target)
      new(graph, source: source, target: target).search.get_distance
    end

    def self.connected?(graph, source, target)
      !get_path(graph, source, target).nil?
    end

    def stack
      @stack ||= [@source]
    end

    def search(target: nil)
      until stack.empty?
        node = get_node(stack.pop)
        break if target && target == node.key

        unless node.visited?
          node.visit!
          @graph.neighbors(node.key).each do |neighbor|
            neighbor_node = get_node(neighbor)
            connect(node, neighbor_node)
            stack.push(neighbor)
          end
        end
      end

      self
    end
  end
end
