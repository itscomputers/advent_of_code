require "algorithms/graph_search"
require "data_structures/binary_heap"

module Algorithms
  class Djikstra < GraphSearch
    def self.get_shortest_path(graph, source, target)
      new(graph, source: source, target: target).search.get_path
    end

    def self.get_distance(graph, source, target)
      new(graph, source: source, target: target).search.get_distance
    end

    def self.connected?(graph, source, target)
      !get_shortest_path(graph, source, target).nil?
    end

    def priority_queue
      @priority_queue ||= DataStructures::BinaryHeap::Min.new(@node)
    end

    def search(target: nil)
      until priority_queue.empty?
        node = priority_queue.pop
        break if target && target == node.key
        next if node.visited?
        node.visit!

        @graph.neighbors(node.key).each do |neighbor|
          neighbor_node = get_node(neighbor)
          distance = node.distance + @graph.distance(node.key, neighbor)
          if neighbor_node.distance.nil? || distance < neighbor_node.distance
            connect(node, neighbor_node)
            priority_queue.push(neighbor_node)
          end
        end
      end

      self
    end
  end
end
