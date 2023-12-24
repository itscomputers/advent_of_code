require "algorithms/graph_search"
require "data_structures/binary_heap"

module Algorithms
  class Djikstra < GraphSearch
    def self.get_shortest_path(graph, source, target)
      new(graph, source: source, target: target).search(target: target).get_path
    end

    def self.get_distance(graph, source, target)
      new(graph, source: source, target: target).search(target: target).get_distance
    end

    def self.connected?(graph, source, target)
      !get_shortest_path(graph, source, target).nil?
    end

    def priority_queue
      @priority_queue ||= DataStructures::BinaryHeap::Min.new(@node)
    end

    def search(target: @target)
      until priority_queue.empty?
        node = priority_queue.pop
        break if finished?(node, target: target)

        neighbors(node).each do |neighbor|
          if neighbor.distance.nil? || improved_distance?(node, neighbor)
            connect(node, neighbor)
            priority_queue.push(neighbor)
          end
        end
      end

      self
    end

    def improved_distance?(node, neighbor)
      node.distance + distance(node, neighbor) < neighbor.distance
    end

    def finished?(node, target: @target)
      target && target == node.key
    end
  end
end
