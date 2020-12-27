require 'solver'
require 'tree'

module Year2019
  class Day06 < Solver
    def part_one
      tree.nodes.sum { |node| node.ancestors.size }
    end

    def part_two
      tree.distance(*labels.map { |label| tree.node_for label })
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

