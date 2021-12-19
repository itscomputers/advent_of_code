require "solver"
require "set"

module Year2021
  class Day12 < Solver
    def solve(part:)
      cave_graph.compute_paths!.path_count_using_extensions
    end

    def cave_graph
      @cave_graph ||= CaveGraph.build_from(lines)
    end

    class CaveGraph
      REGEX = /([\w\W]+)-([\w\W]+)/

      attr_accessor :edge_lookup, :frontier, :paths, :cycles

      def self.build_from(lines)
        new.tap do |graph|
          lines.each do |line|
            graph.add_edges(*REGEX.match(line).to_a.drop(1))
          end
        end
      end

      def initialize
        @edge_lookup = Hash.new { |h, k| h[k] = [] }
        @frontier = [["start"]]
        @paths = Set.new
        @cycles = Set.new
      end

      def inspect
        "<Graph nodes=#{@edge_lookup.keys}>"
      end

      def add_edges(edge, other)
        @edge_lookup[edge] << other
        @edge_lookup[other] << edge
        self
      end

      def neighbors_of(cave)
        @edge_lookup.dig(cave) || []
      end

      def compute_paths!
        split(@frontier.shift) until @frontier.empty?
        self
      end

      def split(path)
        neighbors_of(path.last).each do |neighbor|
          if path.include?(neighbor)
            if neighbor.upcase == neighbor
              @cycles.add(path.drop_while { |element| element != neighbor })
            end
            nil
          else
            new_path = [*path, neighbor]
            if new_path.terminal?
              @paths.add(new_path)
            else
              @frontier << new_path
            end
          end
        end
      end

      def cycles_for(path)
        simple_cycles = simple_cycles_for(path)
        (0..simple_cycles.size).flat_map do |number|
          simple_cycles.permutation(number).map do |permutation|
            permutation.flatten.repeated_lower_case? ? nil : permutation.flatten
          end
        end.compact
      end

      def extensions_for(path)
        simple_cycles = simple_cycles_for(path)
        (1..simple_cycles.size).flat_map do |number|
          simple_cycles.permutation(number).select do |compound|
            compound.reduce(:&).all?(&:upcase)
          end
        end.uniq
      end

      def path_count_using_extensions
        @paths.sum { |path| 1 + extensions_for(path).size }
      end

      def unique_paths
        @paths.flat_map do |path|
          cycles_for(path).map do |cycle|
            path.with_cycle(cycle)
          end
        end
      end

      def old_unique_paths
        @paths.flat_map do |path|
          old_cycles_for(path).map do |cycle|
            path.with_cycle(cycle)
          end
        end.uniq
      end

      def path_count
        unique_paths.size
      end

      def simple_cycles_for(path)
        @cycles.select { |cycle| (cycle & path).to_a == [cycle.first] }
      end


      def old_cycles_for(path)
        simple_cycles = simple_cycles_for(path)
        (0..simple_cycles.size).flat_map do |number|
          simple_cycles.permutation(number).map(&:flatten)
        end
      end

      def old_path_count
        @paths.sum { |path| old_cycles_for(path).size }
      end

      def oldest_path_count
        @paths.sum { |path| PermutationCount.of(simple_cycles_for(path).size) }
      end

      class PermutationCount
        HASH = {0 => 1}

        def self.of(number)
          return HASH[number] if HASH.key?(number)
          number * of(number - 1) + 1
        end
      end
    end
  end
end

class String
  def upcase?
    self == upcase
  end
end

class Array
  def terminal?
    last == "end"
  end

  def cyclic_with?(element)
    include?(element) && element.upcase?
  end

  def invalid_with?(element)
    include?(element) && !element.upcase?
  end

  def counts_hash
    reduce(Hash.new(0)) do |hash, element|
      { **hash, element => (hash.dig(element) || 0) + 1 }
    end
  end

  def repeated_lower_case?
    counts_hash.any? { |element, count| count > 1 && !element.upcase? }
  end

  def with_cycle(cycle)
    overlap = cycle & self
    return self unless overlap.size == 1
    idx = index(overlap.first)
    [*take(idx), *overlap, *drop(idx)]
  end
end
