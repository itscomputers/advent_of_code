require "binary_heap"
require "set"

class Dijkstra
  def initialize(graph, start, targets: nil)
    @graph = graph
    @start = start
    @targets = targets || @graph.nodes

    @distance_lookup = {@start => 0}

    @visited = Set.new
    @frontier = MinBinaryHeap.new << path(@start)
  end

  def distances
    @distance_lookup.slice(*@targets)
  end

  def path(node)
    Path.new(node, @distance_lookup[node])
  end

  def inspect
    "<Dijkstra visited=#{@visited.size} frontier=#{@frontier}>"
  end
  alias_method :to_s, :inspect

  def distance(node)
    @distance_lookup[node]
  end

  def advance
    return if finished?

    node = @frontier.pop.node
    return unless @visited.add?(node)

    neighbors = @graph.neighbors(node)
    neighbors.each do |neighbor|
      distance = distance(node) + @graph.distance(node, neighbor)
      if distance(neighbor).nil? || distance(neighbor) > distance
        @distance_lookup[neighbor] = distance
      end
      @frontier << path(neighbor) unless @visited.include?(neighbor)
    end
    self
  end

  def finished?
    @frontier.empty? || @visited.size == @graph.size
  end

  def execute
    advance until finished?
    self
  end

  class Path < Struct.new(:node, :priority)
    include Comparable

    def <=>(other)
      priority <=> other.priority
    end
  end
end
