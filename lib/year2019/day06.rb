require 'solver'
require 'tree'

module Year2019
  class Day06 < Solver
    def solve(part:)
      case part
      when 1 then tree.nodes.sum { |node| node.ancestors.size }
      when 2 then tree.distance(*labels.map { |label| tree.node_for(label) }) - 2
      end
    end

    def labels
      %w(YOU SAN)
    end

    def tree
      @tree ||= Tree::Builder
        .new(edges: lines, separator: ')')
        .build(include_children: false)
        .tree
    end
  end
end

