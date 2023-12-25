require "solver"
require "range_monkeypatch"

module Year2023
  class Day19 < Solver
    def solve(part:)
      case part
      when 1 then accepted_parts.map(&:rating).sum
      when 2 then combinations
      else nil
      end
    end

    def workflows
      @workflows ||= chunks.first&.split("\n").map { |line| Workflow.build(line) }
    end

    def parts
      chunks.last&.split("\n").map { |line| Part.build(line) }
    end

    def accepted_parts
      parts.select { |part| classifier.classify(part) == "A" }
    end

    def classifier
      @classifier ||= PartClassifier.new(workflows)
    end

    def accepted_paths
      @accepted_paths ||= WorkflowGraph.build(workflows).accepted_paths
    end

    def combinator
      @combinator ||= AcceptedCombinator.new(workflows)
    end

    def combinations
      accepted_paths.map { |path| combinator.combinations_for(path) }.sum
    end

    class AcceptedCombinator
      def initialize(workflows)
        @workflows = workflows.map { |workflow| [workflow.name, workflow] }.to_h
      end

      def workflow(name)
        @workflows[name]
      end

      def default_ranges
        [%w(x m a s).map { |attr| [attr, 1..4000] }.to_h]
      end

      def ranges_for(path)
        path.each_cons(2).reduce(default_ranges) do |ranges, (prev, curr)|
          merge(ranges, workflow(prev).ranges[curr])
        end
      end

      def combinations_for(path)
        ranges_for(path)
          .map { |ranges| ranges.values.map(&:size).reduce(&:*) }
          .sum
      end

      def merge(range_lookups, other_range_lookups)
        range_lookups.product(other_range_lookups).map do |(ranges, other_ranges)|
          %w(x m a s).map do |key|
            [
              key,
              ranges[key].intersection(other_ranges[key]),
            ]
          end.to_h
        end
      end
    end

    class Part < Struct.new(:x, :m, :a, :s)
      def self.build(line)
        new(*line.scan(/\d+/).map(&:to_i))
      end

      def rating
        self.x + self.m + self.a + self.s
      end
    end

    class PartClassifier
      def initialize(workflows)
        @workflows = workflows.map { |workflow| [workflow.name, workflow] }.to_h
      end

      def workflow
        @workflows[@name]
      end

      def classify(part)
        @name = "in"
        until %w(A R).include?(@name)
          @name = workflow.run(part)
        end
        @name
      end
    end

    class Rule
      attr_reader :destination, :attr

      REGEX = Regexp.compile(/(?<attr>[xmas])(?<sym>[<>])(?<val>\d+):(?<dest>\w+)/)

      def self.build(str)
        match = REGEX.match(str)
        return new(str) if match.nil?
        new(match[:dest], attr: match[:attr], sym: match[:sym], val: match[:val].to_i)
      end

      def initialize(destination, attr: nil, sym: nil, val: nil)
        @destination = destination
        @attr = attr
        @sym = sym
        @val = val
      end

      def default?
        @attr.nil? && @sym.nil? && @val.nil?
      end

      def satisfied?(part)
        default? ? true : range.include?(part.send(@attr))
      end

      def range
        @range ||= begin
          if default?
            1..4000
          elsif @sym == "<"
            1..@val-1
          else
            @val+1..4000
          end
        end
      end

      def satisfying_count
        return nil if default?
        @sym == "<" ? @val - 1 : 4000 - @val
      end
    end

    class Workflow < Struct.new(:name, :rules)
      def self.build(line)
        name, rules_str = line.split("{")
        rules = rules_str.delete_suffix("}").split(",").map do |str|
          Rule.build(str)
        end
        new(name, rules)
      end

      def run(part)
        rules.each do |rule|
          return rule.destination if rule.satisfied?(part)
        end
        "R"
      end

      def ranges
        @ranges ||= RangeBuilder.new(self).build
      end

      class RangeBuilder
        def initialize(workflow)
          @rules = workflow.rules.dup
          @range_lookup = Hash.new { |h, k| h[k] = [] }
          @ranges = [%w(x m a s).map { |attr| [attr, 1..4000] }.to_h]
        end

        def build
          handle_rule(@rules.shift) until @rules.empty?
          @range_lookup
        end

        def handle_rule(rule)
          @range_lookup[rule.destination] += intersections(rule)
          unless rule.default?
            @ranges.each do |range|
              range[rule.attr] = range[rule.attr].subtract(rule.range).first
            end
          end
        end

        def intersections(rule)
          return @ranges if rule.default?
          @ranges.map do |range|
            {
              **range,
              rule.attr => range[rule.attr].intersection(rule.range),
            }
          end
        end
      end
    end

    class WorkflowGraph
      def self.build(workflows)
        graph = new
        workflows.each do |workflow|
          workflow.rules.each do |rule|
            graph.add_edge(workflow.name, rule.destination)
          end
        end
        graph
      end

      def initialize
        @lookup = Hash.new { |h, k| h[k] = [] }
      end

      def add_edge(source, target)
        @lookup[source] << target
      end

      def neighbors(key)
        @lookup[key]
      end

      def accepted_paths
        AcceptedPathBuilder.new(self).paths
      end

      class AcceptedPathBuilder
        def initialize(graph)
          @graph = graph
          @unfinished_paths = [["in"]]
          @finished_paths = Set.new
        end

        def paths
          until @unfinished_paths.empty?
            path = @unfinished_paths.shift
            @graph.neighbors(path.last).each do |neighbor|
              if neighbor == "A"
                @finished_paths << [*path, neighbor]
              elsif neighbor != "R"
                @unfinished_paths << [*path, neighbor]
              end
            end
          end
          @finished_paths
        end
      end
    end
  end
end
