require 'advent/day'

module Advent
  class Day07 < Advent::Day
    DAY = "07"

    def self.sanitized_input
      raw_input.split("\n")
    end

    def self.identifier_regex
      @id_regex ||= Regexp.new(/(?<color>[\w ]+) bags contain/)
    end

    def self.child_regex
      @child_regex ||= Regexp.new(/(?<quantity>\d+) (?<color>[\w ]+) bag[s]?/)
    end

    def initialize(input)
      @rules = input.map { |string| Rule.new(string) }
      @bag_hash = Hash.new
    end

    def solve(part:)
      process_rules!
      case part
      when 1 then shiny_gold_ancestor_count
      when 2 then shiny_gold_interior_count
      end
    end

    def shiny_gold_ancestor_count
      bag_for("shiny gold").ancestors.count
    end

    def shiny_gold_interior_count
      bag_for("shiny gold").interior_count
    end

    def bag_for(color)
      @bag_hash[color] ||= Bag.new(color)
    end

    def process_rules!
      @rules.each do |rule|
        parent = bag_for(rule.parent_color)
        rule.children_data.each do |hash|
          child = bag_for(hash[:color])
          parent.add_child(child, hash[:quantity])
          child.add_parent(parent)
        end
      end
    end

    class Bag
      attr_reader :color, :child_hash, :parents

      def initialize(color)
        @color = color
        @child_hash = Hash.new
        @parents = Set.new
      end

      def inspect
        "<Bag @color=#{@color} @parents=#{parents.map(&:color)} @children=#{children.map(&:color)}>"
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
        @interior_count ||= @child_hash.reduce(0) do |count, (bag, quantity)|
          count + quantity * (1 + bag.interior_count)
        end
      end

      def children
        @child_hash.keys
      end

      def add_child(bag, quantity)
        @child_hash[bag] ||= quantity
      end

      def add_parent(bag)
        @parents.add bag
      end

      def eql?(other)
        @color == other.color
      end

      def ==(other)
        eql? other
      end

      def hash
        @color.hash
      end
    end

    class Rule
      def initialize(string)
        @string = string
      end

      def parent_color
        @parent ||= Advent::Day07.identifier_regex.match(@string)[:color]
      end

      def children_data
        @children ||=
          if child_free?
            []
          else
            @string.split(",").map do |substring|
              match = Advent::Day07.child_regex.match(substring)
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

