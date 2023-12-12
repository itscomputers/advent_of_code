require "solver"

module Year2023
  class Day08 < Solver
    def solve(part:)
      case part
      when 1 then graph.traverse("AAA", "ZZZ")
      when 2 then graph.multi_traverse
      end
    end

    def graph
      @graph ||= Graph.new(lines.first&.chars).tap do |graph|
        chunks.drop(1).first&.split("\n").each do |line|
          name, pair = line.split(" = ")
          left, right = pair.split(", ")
          graph.add_edges(name, left[1..], right[...-1])
        end
      end
    end

    class Graph
      def initialize(instructions)
        @lookup = Hash.new
        @instructions = instructions
      end

      def get_node(name)
        @lookup[name] ||= Node.new(name, nil, nil)
      end

      def add_edges(name, left, right)
        get_node(name).tap do |node|
          node.left = get_node(left)
          node.right = get_node(right)
        end
      end

      def traverse(source, destinations)
        destinations = Array(destinations)
        count = 0
        node = get_node(source)
        until destinations.include?(node.name)
          instruction = @instructions[count % @instructions.size]
          node = instruction == "R" ? node.right : node.left
          count += 1
        end
        count
      end

      def multi_traverse
        destinations = @lookup.keys.select { |name| name.end_with?("Z") }
        @lookup
          .keys
          .select { |name| name.end_with?("A") }
          .map { |source| traverse(source, destinations) }
          .reduce(1) { |acc, count| acc.lcm(count) }
      end

      class Node < Struct.new(:name, :left, :right)
      end
    end
  end
end
