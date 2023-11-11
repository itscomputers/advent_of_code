module Algorithms
  class GraphSearch
    def initialize(graph, source:, target: nil)
      @graph = graph
      @source = source
      @target = target
      @node = Node.source(source)
      @nodes = {source => @node}
    end

    def has_node?(key)
      @nodes.key?(key)
    end

    def get_node(key)
      @nodes[key] ||= Node.new(key)
    end

    def get_path(target: @target)
      return unless has_node?(target)
      PathBuilder.new(nodes, target).build.tap do |path|
        return unless path.first == @source
      end
    end

    def get_distance(target: @target)
      return unless has_node?(target)
      get_node(target).distance || compute_distance(target)
    end

    private

    def nodes
      @nodes ||= Hash.new
    end

    def connect(prev_node, next_node)
      next_node.set_prev(@graph, prev_node)
    end

    def compute_distance(target)
      get_path(target: target).each_cons(2).reduce do |acc, (prev, curr)|
        acc + @graph.distance(prev, curr)
      end
    end

    class Node
      include Comparable

      attr_reader :key, :prev, :distance

      def self.source(key)
        new(key).tap do |node|
          node.instance_variable_set(:@distance, 0)
        end
      end

      def initialize(key)
        @key = key
        @visited = false
        @prev = nil
        @distance = nil
      end

      def inspect
        "<GraphSearch::Node k=#{@key} v=#{@visited} p=#{@prev&.key} d=#{@distance}>"
      end

      def visited?
        @visited
      end

      def visit!
        @visited = true
      end

      def set_prev(graph, prev)
        @prev = prev
        unless prev.distance.nil?
          @distance = prev.distance + graph.distance(prev.key, @key)
        end
      end

      def <=>(other)
        @distance <=> other.distance
      end
    end

    class PathBuilder
      def initialize(nodes, target)
        @nodes = nodes
        @node = @nodes[target]
        @path = [target]
      end

      def build
        until @node.prev.nil?
          @node = @node.prev
          @path = [@node.key, *@path]
        end
        @path
      end
    end
  end
end
