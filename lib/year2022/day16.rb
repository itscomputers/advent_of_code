require "a_star"
require "binary_heap"
require "forwardable"
require "graph"
require "set"
require "solver"

module Year2022
  class Day16 < Solver
    def solve(part:)
      case part
      when 1 then optimal_pressure
      end
    end

    def initial_graph
      Graph::Builder.new(lines, graph: Graph.new).build
    end

    def pruned_graph
      initial_graph.prune!
    end

    def valve_graph
      @valve_graph ||= ValveGraph.new(pruned_graph)
    end

    def valve_release
      ValveRelease.new(valve_graph)
    end

    def optimal_pressure
      valve_release.execute.optimal_pressure
    end

    class ValveRelease
      def initialize(valve_graph)
        @valve_graph = valve_graph
        @path_node_lookup = Hash.new

        @visited = Set.new([valve_graph.root])
        @frontier = MaxBinaryHeap.new << path_root

        @optimal = nil
      end

      def inspect
        "<ValveRelease frontier=#{@frontier.size} visited=#{@visited.size} current=#{@path_node}>"
      end
      alias_method :to_s, :inspect

      def path_root
        @path_root ||= path_node(@valve_graph.root).tap do |p_root|
          p_root.minute = 0
          p_root.pressure = 0
          p_root.priority = 0
          p_root.projected = 0
        end
      end

      def path_node(node)
        @path_node_lookup[node] ||= PathNode.new(node)
      end

      def curr_node
        @path_node.node
      end

      def neighbors
        @valve_graph.neighbors(curr_node)
      end

      def distance(neighbor)
        @valve_graph.distance(curr_node, neighbor)
      end

      def heuristic(node)
        @valve_graph.flow_rate(node) * @valve_graph.neighbors(node).sum { |neighbor| @valve_graph.distance(node, neighbor) + 1 }
      end

      def add_to_frontier?(neighbor)
        path_neighbor = path_node(neighbor)
        minute = @path_node.minute + distance(neighbor)
        flow_rate = @valve_graph.flow_rate(path_neighbor.node)
        pressure = @path_node.pressure + @valve_graph.flow_rate(curr_node) * distance(neighbor)
        projected = pressure + flow_rate * (29 - minute)
        priority = projected

        if path_neighbor.pressure.nil? || path_neighbor.projected < projected
          path_neighbor.from = @path_node
          path_neighbor.minute = minute
          path_neighbor.pressure = pressure
          path_neighbor.priority = priority
          path_neighbor.projected = projected
        end

        @frontier << path_neighbor if @visited.add?(neighbor)
      end

      def advance
        @path_node = @frontier.pop
        if curr_node.final_state?
          @optimal = @path_node
        else
          neighbors.each(&method(:add_to_frontier?))
        end
        self
      end

      def debug
        advance
        advance until "AA,DD,BB,JJ,HH,EE,CC".start_with?(path)
        puts "path: #{path}"
        self
      end

      def path(path_node: @path_node)
        return "unstarted" if path_node.nil?
        result = [path_node]
        result = [result.first.from, *result] until result.first.from.nil?
        result.map(&:node).map(&:value).uniq.join(",")
      end

      def execute
        advance until @optimal || @frontier.empty?
        self
      end

      def optimal_pressure
        @optimal.tap do |path_node|
          puts "path: #{path(path_node: path_node)}, minute: #{path_node.minute}"
        end.projected
      end

      class PathNode < Struct.new(:node)
        include Comparable
        attr_accessor :from, :minute, :pressure, :projected, :priority

        def <=>(other)
          priority <=> other.priority
        end

        def to_s
          "<PathNode node=#{node.value}:#{node.bitmask.state.to_s(2)} pressure=#{pressure}>"
        end
      end
    end

    class ValveGraph < BaseGraph
      def initialize(graph)
        @graph = graph
        @node_lookup = Hash.new
      end

      def nodes
        @graph.nodes
      end

      def node(value, bitmask)
        @node_lookup[[value, bitmask]] ||= Node.new(value, bitmask)
      end

      def root
        @root ||= node("AA", root_bitmask)
      end

      def root_bitmask
        BitMask.new(@graph.nodes).copy_with("AA")
      end

      def neighbors(node)
        if node.on?
          @graph.neighbors(node.value).map do |neighbor|
            node(neighbor, node.bitmask)
          end.reject(&:on?)
        else
          [node(*node.neighbor)]
        end
      end

      def distance(node, neighbor)
        return 1 if node.value == neighbor.value
        @graph.distance(node.value, neighbor.value)
      end

      def shortest_distance(node)
        neighbors(node).map { |neighbor| distance(node, neighbor) }.min
      end

      def flow_rate(node)
        @graph
          .nodes
          .select { |value| node.bitmask.has?(value) }
          .sum { |value| @graph.flow_rate(value) }
      end

      class Node < Struct.new(:value, :bitmask)
        extend Forwardable
        def_delegators :bitmask, :final_state?, :remaining

        def on?
          bitmask.has?(value)
        end

        def neighbor
          [value, bitmask.copy_with(value)]
        end
      end

      class BitMask
        attr_accessor :state

        def initialize(values)
          @values = values.sort
          @value_lookup = @values.map.with_index.to_h
          @state = 0
        end

        def bit(value)
          1 << @value_lookup[value]
        end

        def copy_with(value)
          self.clone.tap do |bitmask|
            bitmask.state = @state | bit(value)
          end
        end

        def has?(value)
          @state & bit(value) == bit(value)
        end

        def final_state?
          @values.all?(&method(:has?))
        end

        def remaining
          (1 << @values.size) - @state
        end
      end
    end

    class Graph < BaseGraph
      def initialize
        @neighbor_lookup = Hash.new { |h, k| h[k] = Hash.new }
        @flow_rate_lookup = Hash.new
        @pruned = false
      end

      def inspect
        "<ValveGraph node_count=#{@neighbor_lookup.size}>"
      end

      def nodes
        @neighbor_lookup.keys
      end

      def add_edge(from:, to:, weight: 1)
        @neighbor_lookup[from][to] = weight
      end

      def neighbors(value)
        @neighbor_lookup[value].keys
      end

      def distance(value, neighbor)
        @neighbor_lookup[value][neighbor]
      end

      def set_flow_rate(value, flow_rate)
        @flow_rate_lookup[value] = flow_rate
      end

      def flow_rate(value)
        @flow_rate_lookup[value]
      end

      def prune!
        return if @pruned
        Pruner.new(self).prune!
        @pruned = true
        self
      end

      class Builder < BaseGraph::Builder
        def process(line)
          flow_rate = line.match(/rate=(\d+)/)[1].to_i
          label, *neighbors = line.scan(/[A-Z]{2}/)

          @graph.set_flow_rate(label, flow_rate)
          neighbors.each do |neighbor|
            @graph.add_edge(from: label, to: neighbor)
          end
        end
      end

      class Pruner
        def initialize(graph)
          @graph = graph
        end

        def flow_nodes
          @flow_nodes ||= @graph.nodes.select { |node| @graph.flow_rate(node) > 0 }
        end

        def neighbor_lookup
          ["AA", *flow_nodes].reduce(Hash.new) do |hash, node|
            hash[node] ||= Hash.new
            flow_nodes.each do |goal|
              next if goal == node
              if hash.key?(goal) && hash[goal].key?(node)
                weight = hash[goal][node]
              else
                weight = AStarGraph.new(node, goal, graph: @graph).execute.min_path_cost
              end
              hash[node][goal] = weight
            end
            hash
          end
        end

        def prune!
          @graph.instance_variable_set(:@neighbor_lookup, neighbor_lookup)
        end

        class AStar < AStarGraph
          def neighbors
            super.keys
          end
        end
      end
    end



























#   def old_initial_graph
#     @old_initial_graph ||= OldInitialGraph::Builder.new(lines).build
#   end

#   def old_valve_graph
#     @old_valve_graph ||= OldValveGraph::Builder.new(initial_graph).build
#   end

#   def optimal_pressure
#     BFS.new(valve_graph).execute.optimal_pressure
#   end

#   class BFS
#     def initialize(valve_graph)
#       @path_node_lookup = Hash.new
#       @visited = Set.new
#       @frontier = MaxBinaryHeap.new

#       start = valve_graph.root
#       bitmask = BitMask.new(valve_graph).tap { |bitmask| bitmask.flip(start) }
#       path_node(start, bitmask).tap do |path_start|
#         path_start.pressure = 0
#         path_start.flow_rate = 0
#         path_start.minute = 0
#         path_start.priority = 0
#         @visited.add(path_start)
#         @frontier << path_start
#       end
#     end

#     def path_node(node, bitmask)
#       @path_node_lookup[[node, bitmask]] ||= PathNode.new(node, bitmask)
#     end

#     def add_to_frontier?(neighbor)
#       path_neighbor = path_node(neighbor, @path_node.bitmask)
#       weight = @path_node.node.weight(neighbor)
#       minute = @path_node.minute + weight + 1
#       pressure = @path_node.projected_pressure(minutes: weight) + neighbor.flow_rate
#       flow_rate = @path_node.flow_rate + neighbor.flow_rate

#       if path_neighbor.pressure.nil? || path_neighbor.pressure < pressure
#         path_neighbor.pressure = pressure
#         path_neighbor.flow_rate = flow_rate
#         path_neighbor.minute = minute
#         path_neighbor.from = @path_node
#         path_neighbor.priority = path_neighbor.projected_pressure

#         @frontier << path_neighbor if @visited.add?(path_neighbor)
#       end
#     end

#     def advance
#       @path_node = @frontier.pop
#       @path_node.neighbor_nodes.each(&method(:add_to_frontier?))
#     end

#     def execute
#       advance until @frontier.empty?
#       self
#     end

#     def optimal_pressure
#       @path_node_lookup
#         .values
#         .select(&:terminal?)
#         .map(&:projected_pressure)
#         .max
#     end

#     class PathNode < Struct.new(:node, :bitmask)
#       include Comparable
#       attr_accessor :pressure, :flow_rate, :minute, :from, :priority

#       def <=>(other)
#         priority <=> other.priority
#       end

#       def projected_pressure(minutes: nil)
#         minutes = (30 - minute) if minutes.nil?
#         pressure + flow_rate * minutes
#       end

#       def neighbor_nodes
#         node.neighbors.reject do |neighbor|
#           bitmask.on?(neighbor)
#         end
#       end

#       def terminal?
#         bitmask.final_state?
#       end
#     end

#     class BitMask
#       attr_reader :state

#       def initialize(valve_graph)
#         @nodes = valve_graph.nodes.sort_by(&:value)
#         @node_lookup = @nodes.map.with_index.to_h
#         @state = 0
#         @final_state = 1 << @nodes.size
#       end

#       def bit(node)
#         1 << @node_lookup[node]
#       end

#       def flip(node)
#         @state = @state ^ bit(node)
#       end

#       def final_state?
#         @state == @final_state
#       end

#       def on?(node)
#         @state & bit(node) == bit(node)
#       end
#     end
#   end

#   class Path
#     attr_reader :nodes, :pressure_by_minute

#     def initialize(nodes, pressure_by_minute: nil, limit: nil)
#       @nodes = nodes
#       @pressure_by_minute = pressure_by_minute || {0 => 0}
#       @limit = limit
#       @completed = false
#     end

#     def inspect
#       "<Path #{@nodes.map(&:value).join("-")} minute=#{minute}, pressure=#{pressure}>"
#     end
#     alias_method :to_s, :inspect

#     def edges
#       @nodes.last.edges.values
#     end

#     def completed?
#       @completed || (!@limit.nil? && minute > @limit)
#     end

#     def minute
#       @pressure_by_minute.keys.max
#     end

#     def pressure
#       @pressure_by_minute[minute]
#     end

#     def total_pressure
#       @pressure_by_minute.values.sum + pressure * (@limit - minute - 1)
#     end

#     def split!
#       new_paths = edges.map do |edge|
#         next if @nodes.include?(edge.target)
#         new_pressure = {}
#         edge.weight.times.each do |index|
#           new_pressure[minute + index + 1] = pressure
#         end
#         new_pressure[minute + edge.weight + 1] = pressure + edge.target.flow_rate
#         Path.new(
#           [*@nodes, edge.target],
#           pressure_by_minute: {
#             **@pressure_by_minute,
#             **new_pressure,
#           },
#           limit: @limit,
#         )
#       end.compact
#       if new_paths.empty?
#         @completed = true
#         [self]
#       else
#         new_paths
#       end
#     end

#     def all_paths
#       @paths ||= [self]
#       until @paths.all?(&:completed?)
#         puts "splitting #{@paths.size} paths"
#         @paths = @paths.flat_map(&:split!)
#       end
#       @paths
#     end

#     class Finder
#       def initialize(node, minutes_limit)
#         @node = node
#         @minutes_limit = minutes_limit
#       end

#       def base_path
#         Path.new([@node], limit: @minutes_limit)
#       end

#       def paths
#         @paths ||= base_path.all_paths
#       end

#       def optimal_path
#         @optimal_path ||= paths
#           .select { |path| path.minute <= @minutes_limit }
#           .max_by(&:total_pressure)
#       end

#       def optimal_pressure
#         optimal_path.total_pressure
#       end
#     end
#   end

#   class OldValveGraph < Graph
#     def root
#       node("AA")
#     end

#     class Node < Graph::Node
#       attr_accessor :flow_rate
#     end

#     class Builder
#       def initialize(graph)
#         @graph = graph
#       end

#       def flow_nodes
#         @flow_nodes ||= @graph.nodes.select { |node| node.flow_rate > 0 }
#       end

#       def root
#         @graph.node("AA")
#       end

#       def edge_hash
#         [root, *flow_nodes].reduce(Hash.new) do |hash, node|
#           hash[node.value] ||= Hash.new
#           flow_nodes.each do |goal|
#             next if goal == node
#             if hash.key?(goal.value) && hash[goal.value].key?(node.value)
#               weight = hash[goal.value][node.value]
#             else
#               weight = AStarSimple.new(node, goal).execute.min_path_cost
#             end
#             hash[node.value][goal.value] = weight
#           end
#           hash
#         end
#       end

#       def build
#         Graph::DirectedGraphBuilder.new(
#           edge_hash,
#           graph: ValveGraph.new,
#         ).build.tap do |valve_graph|
#           valve_graph.nodes.each do |node|
#             node.flow_rate = @graph.node(node.value).flow_rate
#           end
#         end
#       end
#     end
#   end

#   class OldInitialGraph < Graph
#     class Node < Graph::Node
#       attr_accessor :flow_rate
#     end

#     class Builder
#       def initialize(lines)
#         @lines = lines
#         @graph = InitialGraph.new
#       end

#       def build
#         @lines.each do |line|
#           flow_rate = line.match(/rate=(\d+)/)[1].to_i
#           label, *neighbor_labels = line.scan(/[A-Z]{2}/)

#           @graph.node(label).tap do |node|
#             node.flow_rate = flow_rate
#             neighbor_labels.each do |neighbor_label|
#               node.add_edge(@graph.node(neighbor_label), 1)
#             end
#           end
#         end
#         @graph
#       end
#     end
#   end


  end
end
