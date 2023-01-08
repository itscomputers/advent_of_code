require "a_star"
require "dijkstra"
require "graph"
require "set"
require "solver"

module Year2022
  class Day16 < Solver
    def solve(part:)
      valve_tunnel(part: part).search.optimal_pressure
    end

    def initial_graph
      Graph::Builder.new(lines, graph: Graph.new).build
    end

    def pruned_graph
      @pruned_graph ||= initial_graph.prune!
    end

    def valve_tunnel(part:)
      case part
      when 1 then ValveTunnel.new(pruned_graph, worker_count: 1, allotted_time: 30)
      when 2 then ValveTunnel.new(pruned_graph, worker_count: 2, allotted_time: 26)
      end
    end

    class ValveTunnel
      attr_reader :paths, :completed_paths

      def initialize(graph, worker_count:, allotted_time:)
        @graph = graph
        @worker_count = worker_count
        @allotted_time = allotted_time

        @paths = [start_path]
        @completed_paths = []
      end

      def inspect
        "<ValveTunnel remaining=#{@paths.size}, completed=#{@completed_paths.size}, optimal=#{optimal_pressure}>"
      end

      def start_path
        Path.new(@worker_count.times.map { start_worker }, [], -1, 0, 0)
      end

      def start_worker
        Worker.new("AA", 0)
      end

      def extend_paths
        @paths = @paths.flat_map(&method(:child_paths)).uniq
        self
      end

      def reduce_paths
        @paths = @paths.group_by(&:labels).values.flat_map do |path_group|
          path_group.sort_by(&method(:projected)).last(2)
        end
      end

      def search
        iteration = 0
        until @paths.empty?
          iteration += 1
          puts "-----\niteration: #{iteration} ~> #{inspect}"
          extend_paths
          reduce_paths
        end
        self
      end

      def optimal_pressure
        @completed_paths.map(&method(:projected)).max
      end

      def child_paths(path)
        if path.visited.size == @graph.size
          @completed_paths << path
          return []
        end
        feasible, impossible = path_extender(path).child_paths.partition do |child_path|
          child_path.minute <= @allotted_time
        end
        @completed_paths << path unless impossible.empty?
        feasible
      end

      def path_extender(path)
        case path.workers.size
        when 1 then PathExtender.new(path, @graph)
        else PathExtenderComplex.new(path, @graph)
        end
      end

      def projected(path)
        path.projected_pressure(@graph, @allotted_time)
      end

      class Path < Struct.new(:workers, :visited, :minute, :flow_rate, :pressure)
        def remaining_labels(graph)
          @graph.nodes - labels
        end

        def valid_workers(allotted_time)
          workers.compact.select { |worker| minute + worker.distance + 1 < allotted_time }
        end

        def projected_pressure(graph, allotted_time)
          [
            pressure,
            flow_rate * (allotted_time - minute),
            valid_workers(allotted_time).sum { |worker| graph.flow_rate(worker.destination) * (allotted_time - minute - worker.distance - 1) },
          ].sum
        end

        def to_a
          [visited, minute, pressure, flow_rate, workers.compact.map(&:to_a)]
        end

        def labels
          @labels ||= Set.new([*visited, *workers.compact.map(&:destination)])
        end

        def ==(other)
          (workers == other.workers || workers == other.workers.reverse) &&
            visited.sort == other.visited.sort &&
            minute == other.minute &&
            flow_rate == other.flow_rate &&
            pressure == other.pressure
        end

        def eql?(other)
          self == other
        end

        def hash
          [
            *workers.compact.map(&:destination).sort,
            *workers.compact.map(&:distance).sort,
            visited,
            minute,
            flow_rate,
            pressure,
          ].hash
        end
      end

      class Worker < Struct.new(:destination, :distance)
      end

      class PathExtender
        def initialize(path, graph)
          @path = path
          @graph = graph
        end

        def child_paths
          new_workers_for(worker).map do |worker|
            Path.new([worker], visited, minute, flow_rate, pressure)
          end
        end

        def workers
          @path.workers
        end

        def labels
          @path.labels
        end

        def worker
          workers.first
        end

        def travel_distance
          worker.distance
        end

        def worker_partition
          @worker_partition ||= workers.compact.partition { |worker| worker.distance == travel_distance }
        end

        def available_workers
          worker_partition.first
        end

        def unavailable_workers
          worker_partition.last
        end

        def flow_rate
          @path.flow_rate + available_workers.sum { |worker| @graph.flow_rate(worker.destination) }
        end

        def visited
          [*@path.visited, *available_workers.map(&:destination).uniq]
        end

        def elapsed_time
          travel_distance + 1
        end

        def minute
          @path.minute + elapsed_time
        end

        def pressure
          @path.pressure + @path.flow_rate * elapsed_time
        end

        def new_destinations(worker)
          return unless worker.distance == travel_distance
          @graph.neighbors(worker.destination).reject { |label| labels.include?(label) }
        end

        def new_workers_for(worker)
          return [nil] if worker.nil?
          if available_workers.include?(worker)
            destinations = new_destinations(worker)
            if destinations.empty?
              [nil]
            else
              destinations.map do |destination|
                Worker.new(destination, @graph.distance(worker.destination, destination))
              end
            end
          else
            [Worker.new(worker.destination, worker.distance - elapsed_time)]
          end
        end
      end

      class PathExtenderComplex < PathExtender
        def child_paths
          new_worker_groups.map do |worker_group|
            Path.new(worker_group, visited, minute, flow_rate, pressure)
          end.uniq
        end

        def travel_distance
          workers.compact.map(&:distance).min
        end

        def new_worker_groups
          groups_by_worker = workers.map(&method(:new_workers_for))
          groups_by_worker.drop(1).reduce(groups_by_worker.first) do |array, worker_group|
            array.product(worker_group).map(&:flatten)
          end.select do |worker_group|
            destinations = worker_group.compact.map(&:destination)
            destinations.uniq == destinations
          end
        end
      end
    end

    class Graph < BaseGraph
      attr_accessor :neighbor_lookup

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

      def size
        @neighbor_lookup.size
      end

      def add_edge(from:, to:, weight: 1)
        @neighbor_lookup[from][to] = weight
      end

      def neighbors(value)
        @neighbor_lookup[value].keys
      end

      def distance(value, neighbor)
        return 0 if value == neighbor
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
            hash[node] ||= distances(node)
            hash
          end
        end

        def distances(node)
          Dijkstra.new(
            @graph,
            node,
            targets: flow_nodes,
          ).execute.distances
        end

        def prune!
          @graph.neighbor_lookup = neighbor_lookup
        end
      end
    end
  end
end
