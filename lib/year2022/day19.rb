require "solver"
require "vector"

module Year2022
  class Day19 < Solver
    KEYS = [:ore, :clay, :obsidian, :geode]

    def solve(part:)
      case part
      when 1 then quality_levels.sum
      when 2 then top_geodes.reduce(&:*)
      end
    end

    def blueprints
      lines.map.with_index { |line, index| Blueprint.build(index, line) }
    end

    def factory_trees
      @factory_trees ||= blueprints.map { |blueprint| FactoryTree.new(blueprint) }
    end

    def quality_levels
      factory_trees.map do |tree|
        tree.build_to(depth: 24).quality_level
      end
    end

    def top_geodes
      factory_trees.take(3).map do |tree|
        tree.build_to(depth: 32).geode_count
      end
    end

    class FactoryTree
      attr_reader :factories, :blueprint

      def initialize(blueprint)
        @blueprint = blueprint
        @factories = [Factory.new(blueprint)]
        @minute = 0
      end

      def build_next_depth
        @factories = @factories.flat_map(&:children)
        @minute += 1
        prune!
        self
      end

      def build_to(depth:)
        build_next_depth until @minute == depth
        self
      end

      def geode_count
        @factories.map(&:geode_count).max
      end

      def quality_level
        geode_count * @blueprint.id
      end

      def prune!
        @factories = @factories.group_by(&:robots).values.flat_map do |factories|
          factories.sort_by { |factory| Vector.dot(factory.resources.values, [1, 2, 4, 8]) }.last(5)
        end
      end
    end

    class Factory
      attr_reader :robots, :resources, :minute

      def initialize(blueprint, robots: nil, resources: nil)
        @blueprint = blueprint
        @robots = robots || Hash.new { |h, k| h[k] = 0 }.tap { |h| h[:ore] = 1 }
        @resources = resources || Hash.new { |h, k| h[k] = 0 }
        @new_robots = Hash.new { |h, k| h[k] = 0 }
      end

      def children
        [nil, *KEYS].map(&method(:build_child)).compact
      end

      def build_child(robot)
        return if skip_build?(robot)
        Factory
          .new(@blueprint, robots: @robots.dup, resources: @resources.dup)
          .resolve_child(robot: robot)
      end

      def resolve_child(robot:)
        build_new(robot)
        collect_resources
        collect_robots
        self
      end

      def build_new(robot)
        return if robot.nil?
        return unless @blueprint.can_build?(robot, with: @resources)
        @blueprint[robot].to_h.each {|key, value| @resources[key] -= value }
        @new_robots[robot] += 1
      end

      def collect_resources
        @robots.each { |key, value| @resources[key] += value  }
      end

      def collect_robots
        @new_robots.each do |key, value|
          @robots[key] += value
          @new_robots[key] -= value
        end
        self
      end

      def skip_build?(robot)
        return false if robot.nil?
        return true unless @blueprint.can_build?(robot, with: @resources)
        [:ore, :clay, :obsidian].any? { |key| @robots[key] > @blueprint.max_cost(key) }
      end

      def geode_count
        @resources[:geode]
      end
    end

    class Blueprint < Struct.new(:id, :ore, :clay, :obsidian, :geode)
      def self.build(index, line)
        Builder.new(index, line).build
      end

      def can_build?(robot, with:)
        send(robot).to_h.all? { |key, value| with[key] >= value }
      end

      def max_costs
        @max_costs ||= [:ore, :clay, :obsidian].map do |key|
          [key, KEYS.map { |robot| send(robot)[key] }.max]
        end.to_h
      end

      def max_cost(key)
        max_costs[key]
      end

      class Builder
        def initialize(index, line)
          @index = index
          @line = line
        end

        def ore
          Cost.new(@line.match(/Each ore robot costs (\d+) ore./)[1].to_i, 0, 0)
        end

        def clay
          Cost.new(@line.match(/Each clay robot costs (\d+) ore./)[1].to_i, 0, 0)
        end

        def obsidian
          match = @line.match(/Each obsidian robot costs (?<ore>\d+) ore and (?<clay>\d+) clay./)
          Cost.new(match[:ore].to_i, match[:clay].to_i, 0)
        end

        def geode
          match = @line.match(/Each geode robot costs (?<ore>\d+) ore and (?<obsidian>\d+) obsidian./)
          Cost.new(match[:ore].to_i, 0, match[:obsidian].to_i)
        end

        def build
          Blueprint.new(@index + 1, ore, clay, obsidian, geode)
        end
      end
    end

    class Cost < Struct.new(:ore, :clay, :obsidian)
      def inspect
        "<Cost #{[ore, clay, obsidian].join(",")}>"
      end
      alias_method :to_s, :inspect
    end
  end
end
