require "algorithms/graph_search"
require "algorithms/djikstra"
require "data_structures/binary_heap"

module Algorithms
  class AStar < Algorithms::Djikstra
    def priority_queue
      @priority_queue ||= DataStructures::BinaryHeap::WithComparator.new(@node) do |node, other|
        heuristic(other) <=> heuristic(node)
      end
    end

    private

    def heuristic(node)
      node.distance
    end
  end
end
