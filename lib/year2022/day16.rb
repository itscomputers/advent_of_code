require "a_star"
require "dijkstra"
require "graph"
require "set"
require "solver"

module Year2022
  class Day16 < Solver
    def solve(part:)
      valve_release(part: part).search.optimal_pressure
    end

    def initial_graph
      Graph::Builder.new(lines, graph: Graph.new).build
    end

    def pruned_graph
      @pruned_graph ||= initial_graph.prune!
    end

    def valve_release(part:)
      case part
      when 1 then ValveRelease.new(pruned_graph)
      when 2 then ElephantValveRelease.new(pruned_graph)
      end
    end

    class ElephantValveRelease
      def initialize(graph)
        @graph = graph
        @allotted_time = 26

        @paths = [start_path]
        @completed_paths = []
      end

      def start_worker
        Worker.new(["AA"], nil, nil)
      end

      def start_path
        Path.new(start_worker, start_worker, 0, 0, 0)
      end

      def extend_paths
        @paths = @paths.flat_map do |path|
          if path.visited.size == @graph.nodes.size
            @completed_paths << path
            next
          end
          children, impossible = path.children(@graph).partition do |child|
            child.minute <= @allotted_time
          end
          unless impossible.empty?
            @completed_paths << path
          end
          if children.empty?
            @completed_paths << path.process!(@graph, final: true)
            []
          else
            children
          end
        end.compact
      end

      def reduce_paths
        @paths = @paths.sort_by(&method(:projected)).last(1000000)
       #@paths = @paths.group_by(&:labels).values.flat_map do |path_group|
       #  path_group.sort_by(&method(:projected)).last(10)
       #end
      end

      def search
        @threshold = 10
        @iteration = 1
        while !@paths.empty?
          if true || @iteration % 5 == 0
            puts "path count: #{@paths.size}"
            puts "completed: #{@completed_paths.size}"
          end
          @iteration += 1
          extend_paths
          reduce_paths
          if @completed_paths.size > @threshold
            @threshold += 10
            puts "optimal after #{@completed_paths.size} completed: #{optimal_pressure}"
          end
        end
        self
      end

      def optimal_path
        [*@paths, *@completed_paths].max_by(&method(:projected))
      end

      def optimal_pressure
        projected(optimal_path)
      end

      def projected(path)
        path.pressure + path.flow_rate * (@allotted_time - path.minute)
      end

      class Worker < Struct.new(:visited, :destination, :distance)
        def labels
          [*visited, destination].compact
        end

        def neighbors(graph)
          return [nil] unless destination.nil?
          graph.neighbors(visited.last).reject { |label| visited.include?(label) }
        end

        def copy_with(label, graph)
          Worker.new(
            visited,
            destination || label,
            distance || graph.distance(visited.last, label),
          )
        end

        def visit_destination!
          self.visited = [*visited, destination]
          self.destination = nil
          self.distance = nil
        end
      end

      class Path < Struct.new(:person, :elephant, :minute, :flow_rate, :pressure)
        def workers
          [person, elephant]
        end

        def labels
          workers.flat_map(&:labels).sort
        end

        def visited
          workers.flat_map(&:visited).uniq
        end

        def neighbors(graph)
          person
            .neighbors(graph)
            .reject { |label| elephant.labels.include?(label) }
            .product(
              elephant
                .neighbors(graph)
                .reject { |label| person.labels.include?(label) }
            )
            .select { |pair| pair == pair.uniq }
        end

        def children(graph)
          neighbors(graph).map do |labels|
            copy_with(labels, graph)
          end
        end

        def copy_with(labels, graph)
          Path.new(
            *workers.zip(labels).map { |(worker, label)| worker.copy_with(label, graph) },
            minute,
            flow_rate,
            pressure,
          ).process!(graph)
        end

        def process!(graph, final: false)
          distances = workers.map(&:distance)
          return self unless final || !distances.any?(&:nil?)

          distance = distances.compact.min
          return self if distance.nil?

          self.minute += distance + 1
          self.pressure += self.flow_rate * (distance + 1)

          completed, remaining = workers.partition { |worker| worker&.distance == distance }
          completed.each do |completed|
            self.flow_rate += graph.flow_rate(completed.destination)
            completed.visit_destination!
          end
          remaining.each do |remaining|
            next if remaining.destination.nil?
            remaining.distance -= distance + 1
          end

          self
        end
      end
    end

    class ValveRelease
      attr_reader :paths

      def initialize(graph)
        @graph = graph
        @paths = start_paths
        @completed_paths = []
      end

      def allotted_time
        30
      end

      def start_paths
        [self.class::Path.new(["AA"], 0, 0, 0)]
      end

      def distance(path, label)
        @graph.distance(path.labels.last, label) + 1
      end

      def neighbors(path)
        @graph.neighbors(path.labels.last).reject { |label| path.labels.include?(label) }
      end

      def extend_path(path, label)
        Path.new(
          [*path.labels, label],
          path.minute + distance(path, label),
          path.flow_rate + @graph.flow_rate(label),
          path.pressure + path.flow_rate * distance(path, label),
        )
      end

      def extend_paths
        @paths = @paths.flat_map do |path|
          neighbors(path).map do |label|
            new_path = extend_path(path, label)
            if new_path.minute > allotted_time
              @completed_paths << path
              nil
            else
              new_path
            end
          end.compact
        end
        self
      end

      def reduce_paths
        return
        @paths = @paths
          .group_by { |path| Set.new(path.labels) }
          .flat_map { |_, group| group.sort_by(&method(:projected)).last(10) }
      end

      def search
        (@graph.nodes.size - 1).times do
          extend_paths
          reduce_paths
        end
        self
      end

      def optimal_pressure
        [*@paths, *@completed_paths].map(&method(:projected)).max
      end

      def projected(path)
        path.pressure + path.flow_rate * (allotted_time - path.minute)
      end

      class Path < Struct.new(:labels, :minute, :flow_rate, :pressure)
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
