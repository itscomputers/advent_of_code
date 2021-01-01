require 'solver'

module Year2019
  class Day14 < Solver
    def part_one
      @part_one ||= resolve(fuel_quantity: 1)
    end

    def part_two
      ore_for fuel_quantity: 10**12
    end

    def parse_line(line)
      Reaction.from_string(line)
    end

    def reaction_lookup
      @reaction_lookup ||= parsed_lines.each_with_object(Hash.new) do |reaction, hash|
        hash[reaction.chemical] = reaction
      end
    end

    def resolve(fuel_quantity:)
      ReactionResolver.new(reaction_lookup, fuel_quantity: fuel_quantity).resolve
    end

    def search_range_for(fuel_quantity)
      start = fuel_quantity / part_one
      loop do
        if resolve(fuel_quantity: start) >= fuel_quantity
          start /= 2
          break
        end
        start *= 2
      end
      Range.new(start, 2 * start)
    end

    def ore_for(fuel_quantity:)
      search_range_for(fuel_quantity).bsearch do |quantity|
        resolve(fuel_quantity: quantity) > fuel_quantity
      end - 1
    end

    class Reaction
      def self.chemical_regex
        @chemical_regex ||= /(\d+) ([A-Z]+)/
      end

      def self.from_string(string)
        *inputs, output = string.scan chemical_regex
        ingredients = inputs.each_with_object(Hash.new) do |(quantity, chemical), hash|
          hash[chemical] = quantity.to_i
        end
        new output.last, output.first.to_i, ingredients
      end

      attr_reader :chemical, :quantity, :ingredients

      def initialize(chemical, quantity, ingredients)
        @chemical = chemical
        @quantity = quantity
        @ingredients = ingredients
      end

      def ingredients_for(quantity, extra)
        quo, rem = (quantity - extra).divmod @quantity
        multiplier, extra = rem == 0 ?
          [quo, rem] :
          [quo + 1, @quantity - rem]

        [
          @ingredients.transform_values { |val| val * multiplier },
          extra
        ]
      end

      def inspect
        "<Reaction #{@quantity} #{@chemical} <~ #{@ingredients}>"
      end
    end

    class ReactionResolver
      attr_reader :ingredients, :extra

      def initialize(reaction_lookup, fuel_quantity: nil)
        @reaction_lookup = reaction_lookup
        @ingredients = reaction_for("FUEL").ingredients.transform_values do |value|
          value * (fuel_quantity || 1)
        end
        @extra = Hash.new { |h, k| h[k] = 0 }
      end

      def inspect
        "FUEL <~ #{@ingredients}"
      end

      def reaction_for(chemical)
        @reaction_lookup[chemical]
      end

      def resolve
        update_ingredients! until @ingredients.keys == ["ORE"]
        @ingredients["ORE"]
      end

      def update_ingredients!
        @ingredients = @ingredients.reduce(Hash.new { |h, k| h[k] = 0 }) do |hash, (chem, quant)|
          if chem == "ORE"
            hash[chem] += quant
          else
            reaction = reaction_for chem
            ingredients, @extra[chem] = reaction.ingredients_for quant, @extra[chem]
            ingredients.each do |loc_chem, loc_quant|
              hash[loc_chem] += loc_quant
            end
          end
          hash
        end
        self
      end
    end
  end
end

