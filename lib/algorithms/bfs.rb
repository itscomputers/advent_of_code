require "algorithms/graph_search"

module Algorithms
  class BFS < GraphSearch
    def self.get_shortest_path(graph, source, target)
      new(graph, source: source, target: target).search(target: target).get_path
    end

    def self.get_distance(graph, source, target)
      new(graph, source: source, target: target).search(target: target).get_distance
    end

    def self.connected?(graph, source, target)
      !get_shortest_path(graph, source, target).nil?
    end

    def queue
      @queue ||= [@source]
    end

    def search(target: nil)
      until queue.empty?
        node = get_node(queue.shift)
        node.visit!

        break if target_found?(node, target: target)

        @graph.neighbors(node.key).each do |neighbor|
          neighbor_node = get_node(neighbor)
          unless neighbor_node.visited?
            neighbor_node.visit!
            connect(node, neighbor_node)
            queue.push(neighbor)
          end
        end
      end

      self
    end

    private

    def target_found?(node, target: @target)
      target && target == node.key
    end
  end
end
