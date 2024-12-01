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
      @queue ||= [get_node(@source)]
    end

    def search(target: nil)
      expand_search(target) until queue.empty? || @target_found
      self
    end

    def expand_search(target)
      node = queue.shift
      return if node.nil?
      return if target_found?(node, target: target)
      visit(node)
    end

    def visit(node)
      node.visit!

      neighbors(node).each do |neighbor|
        unless neighbor.visited?
          neighbor.visit!
          connect(node, neighbor)
          queue.push(neighbor)
        end
      end
    end

    private

    def target_found?(node, target: @target)
      (target && target == node.key).tap do |bool|
        @target_found = true if bool
      end
    end
  end
end
