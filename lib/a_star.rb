require "binary_heap"
require "point"
require "set"

class AStarSimple
  attr_reader :path_node

  def initialize(start, goal)
    @start = start
    @goal = goal

    @frontier_nodes = Set.new([@start])
    @frontier = MinBinaryHeap.new << path_node_for(@start).tap do |p_node|
      p_node.cost = 0
      p_node.priority = heuristic(@start)
    end

    @path_found = false
  end

  def heuristic(node)
    node.shortest_distance || 1
  end

  def finished?
    @goal == @path_node.node
  end

  def path_node_lookup
    @path_node_lookup ||= Hash.new
  end

  def path_node_for(node)
    path_node_lookup[node] ||= PathNode.new(node)
  end

  def neighbors
    @path_node.node.neighbors
  end

  def distance(node)
    @path_node.node.weight(node)
  end

  def add_to_frontier?(neighbor)
    cost = @path_node.cost + distance(neighbor)
    path_neighbor = path_node_for(neighbor)
    if path_neighbor.cost.nil? || path_neighbor.cost > cost
      path_neighbor.from = @path_node
      path_neighbor.cost = cost
      path_neighbor.priority = cost + heuristic(neighbor)

      @frontier << path_neighbor if @frontier_nodes.add?(neighbor)
    end
  end

  def advance
    return if @path_found
    @path_node = @frontier.pop
    @path_found = true and return self if finished?
    neighbors.each(&method(:add_to_frontier?))
  end

  def execute
    advance until @path_found || @frontier.empty?
    self
  end

  def min_path_cost
    return unless @path_found
    @path_node&.cost
  end

  def min_path
    @min_path ||= build_min_path
  end

  def build_min_path
    return unless @path_found
    path = [@path_node]
    path = [path.first.from, *path] until path.first.from.nil?
    path
  end

  class PathNode < Struct.new(:node)
    include Comparable
    attr_accessor :cost, :from, :priority

    def <=>(other)
      priority <=> other.priority
    end
  end
end

class AStarDynamic < AStarSimple
  def finished?
    @goal.call(@path_node.node)
  end
end

class AStarGraph < AStarSimple
  def initialize(start, goal, graph:)
    @graph = graph
    super(start, goal)
  end

  def neighbors
    @graph.neighbors(@path_node.node)
  end

  def heuristic(node)
    @graph.shortest_distance(node) || 1
  end

  def distance(node)
    @graph.distance(@path_node.node, node)
  end
end

class AStar
  def initialize(graph, start, static_goal: nil, goal: nil, heuristic: nil)
    @graph = graph
    if static_goal.nil?
      @goal = goal
      @heuristic = heuristic
    else
      @goal = lambda { |node| node == static_goal }
      @heuristic = lambda { |node| Point.distance(node, static_goal) }
    end
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

