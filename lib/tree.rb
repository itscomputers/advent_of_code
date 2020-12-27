class Tree
  def initialize
    @node_lookup = Hash.new
  end

  def nodes
    @node_lookup.values
  end

  def node_for(label)
    @node_lookup[label] ||= Node.new label
  end

  def common_ancestor(*nodes)
    nodes.map(&:ancestors).reduce(:&).first
  end

  def distance(node, other)
    return 0 if node == other
    ancestor = common_ancestor node, other
    [node, other].sum { |n| n.ancestors.index(ancestor) }
  end

  class Node < Struct.new(:label)
    attr_accessor :parent

    def is_root?
      parent.nil?
    end

    def is_leaf?
      children.empty?
    end

    def children
      @children ||= Set.new
    end

    def add_child(node)
      children.add node
    end

    def ancestors
      return [] if is_root?
      @ancestors ||= [parent, *parent.ancestors]
    end

    def descendants
      return [] if is_leaf?
      @descendants ||= [*children, *children.descendants]
    end
  end

  class Builder
    def initialize(edges:, separator: '->')
      @edges = edges
      @separator = separator
    end

    def tree
      @tree ||= Tree.new
    end

    def build(include_children: true)
      @edges.each do |edge|
        parent, child = edge.split(@separator).map { |label| tree.node_for label }
        child.parent = parent
        parent.add_child(child) if include_children
      end
      self
    end
  end
end

