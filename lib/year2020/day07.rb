require 'solver'

module Year2020
  class Day07 < Solver
    def part_one
      bag_for("shiny gold").ancestors.count
    end

    def part_two
      bag_for("shiny gold").interior_count
    end

    def initialize
      lines.each do |string|
        rule_parser = RuleParser.new string
        parent = bag_for rule_parser.parent_color
        rule_parser.children_data.each do |hash|
          child = bag_for hash[:color]
          parent.add_child child, hash[:quantity]
          child.add_parent parent
        end
      end
    end

    def bag_lookup
      @bag_lookup ||= Hash.new
    end

    def bag_for(color)
      bag_lookup[color] ||= Bag.new(color)
    end

    def process_rules!
      rules.each do |rule|
        parent = bag_for(rule.parent_color)
        rule.children_data.each do |hash|
          child = bag_for(hash[:color])
          parent.add_child(child, hash[:quantity])
          child.add_parent(parent)
        end
      end
    end

    class Bag < Struct.new(:color)
      def child_lookup
        @child_lookup ||= Hash.new
      end

      def parents
        @parents ||= Set.new
      end

      def inspect
        "<Bag @color=#{color} @parents=#{parents.map(&:color)} @children=#{children.map(&:color)}>"
      end

      def to_s
        inspect
      end

      def ancestors
        @ancestors ||= parents.inject(Set.new) do |set, parent|
          set + [*parent.ancestors, parent]
        end
      end

      def interior_count
        @interior_count ||= child_lookup.reduce(0) do |count, (bag, quantity)|
          count + quantity * (1 + bag.interior_count)
        end
      end

      def children
        child_lookup.keys
      end

      def add_child(bag, quantity)
        child_lookup[bag] ||= quantity
      end

      def add_parent(bag)
        parents.add bag
      end
    end

    class RuleParser
      def self.identifier_regex
        @id_regex ||= Regexp.new(/(?<color>[\w ]+) bags contain/)
      end

      def self.child_regex
        @child_regex ||= Regexp.new(/(?<quantity>\d+) (?<color>[\w ]+) bag[s]?/)
      end

      def initialize(string)
        @string = string
      end

      def parent_color
        self.class.identifier_regex.match(@string)[:color]
      end

      def children_data
        if child_free?
          []
        else
          @string.split(",").map do |substring|
            match = self.class.child_regex.match(substring)
            { :quantity => match[:quantity].to_i, :color => match[:color] }
          end
        end
      end

      def child_free?
        @string.end_with? "no other bags."
      end
    end
  end
end

