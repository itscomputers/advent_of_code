require 'solver'

module Year2020
  class Day21 < Solver
    def recipes
      @recipes ||= raw_input.split("\n").map { |string| Recipe.new string }
    end

    def allergen_hash
      @allergen_hash ||= IngredientClassifier
        .new(recipes)
        .deduce_allergens
        .determined_allergens
    end

    def ingredients_with_allergens
      @ingredients_with_allergens ||= allergen_hash.values.to_set
    end

    def part_one
      recipes.reduce(0) do |acc, recipe|
        recipe.ingredients.count do |ingredient|
          !ingredients_with_allergens.include? ingredient
        end + acc
      end
    end

    def part_two
      allergen_hash.sort.map(&:last).join(",")
    end

    class Recipe
      attr_reader :allergens, :ingredients

      def initialize(string)
        ingredient_section, allergen_section = string.split(" (contains ")
        @ingredients = ingredient_section.split(" ").to_set
        @allergens = (allergen_section&.split(")")&.first&.split(", ") || []).to_set
      end
    end

    class IngredientClassifier
      def initialize(recipes)
        @recipes = recipes
      end

      def allergen_hash
        return @allergen_hash unless @allergen_hash.nil?

        @allergen_hash = @recipes.each_with_object(Hash.new) do |recipe, memo|
          recipe.allergens.each do |allergen|
            if memo.key? allergen
              memo[allergen] &= recipe.ingredients
            else
              memo[allergen] = recipe.ingredients
            end
          end
        end
      end

      def ingredients_with_allergens
        determined_allergens.values
      end

      def determined_allergens
        allergen_hash
          .select { |allergen, ingredients| ingredients.size == 1 }
          .transform_values(&:first)
      end

      def undetermined_allergens
        allergen_hash.select { |allergen, ingredients| ingredients.size > 1 }
      end

      def deduce_allergens
        until undetermined_allergens.empty?
          undetermined_allergens.each do |allergen, ingredients|
            allergen_hash[allergen] = ingredients - ingredients_with_allergens
          end
        end
        self
      end
    end
  end
end

