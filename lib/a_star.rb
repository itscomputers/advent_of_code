require 'binary_heap'

class AStar
  def initialize(graph, start, goal: nil, heuristic: nil)
    @graph = graph
    @goal = goal
    @heuristic = heuristic
    @frontier_nodes = Set.new([start])
    @frontier = MinBinaryHeap.new << path_node_for(start).tap do |path_node|
      path_node.cost = 0
      path_node.priority = heuristic start
    end
  end

  def inspect
    "<AStar>"
  end

  def search
    advance until @path_found || @frontier.empty?
    self
  end

  def minimum_path_length
    return unless @path_found
    @path_node.cost
  end

  def minimum_path
    return unless @path_found
    path = [@path_node]
    until path.first.from.nil?
      path = [path.first.from, *path]
    end
    path
  end

  def path_node_lookup
    @path_node_lookup ||= Hash.new
  end

  def path_node_for(node)
    path_node_lookup[node] ||= PathNode.new(node)
  end

  def heuristic(node)
    @heuristic.nil? ? 0 : @heuristic.call(node)
  end

  def pop
    @path_node = @frontier.pop
  end

  def advance
    return if @path_found

    @path_node = @frontier.pop

    if (@goal.nil? ? @path_node.goal? : @goal.call(@path_node.node))
      @path_found = true and return self
    end

    @graph.neighbors_of(@path_node.node).each do |neighbor|
      cost = @path_node.cost + @graph.distance(@path_node.node, neighbor)
      path_neighbor = path_node_for(neighbor)
      if path_neighbor.cost.nil? || path_neighbor.cost > cost
        path_neighbor.from = @path_node
        path_neighbor.cost = cost
        path_neighbor.priority = cost + heuristic(neighbor)

        @frontier << path_neighbor if @frontier_nodes.add? neighbor
      end
    end
  end

  class PathNode < Struct.new(:node)
    include Comparable
    attr_accessor :cost, :from, :priority

    def <=>(other)
      priority <=> other.priority
    end
  end
end

