require 'solver'

module Year2019
  class Day08 < Solver
    def part_one
      image
        .layers
        .min_by { |layer| layer.count_of '0' }
        .count_lookup
        .slice('1', '2')
        .values
        .reduce(:*)
    end

    def part_two
      "\n" + image.display
    end

    def image
      @image ||= Image.new(raw_input.chomp, width, height)
    end

    def width
      25
    end

    def height
      6
    end

    class Image
      def initialize(string, width, height)
        @chars = string.chars
        @width = width
        @height = height
      end

      def top_layer
        Layer.new Array.new(@width * @height) { '2' }
      end

      def layers
        @layers ||= @chars.each_slice(@width * @height).map { |string| Layer.new string }
      end

      def decoded
        @decoded ||= layers.reduce(top_layer) { |upper, lower| upper.combine_with lower }
      end

      def display
        Grid.display(
          decoded.chars.each_slice(@width),
          :type => :rows,
          "0" => " ",
          "1" => "#",
        )
      end
    end

    class Layer
      attr_reader :chars

      def initialize(chars)
        @chars = chars
      end

      def combine_with(other)
        Layer.new @chars.zip(other.chars).map { |(upper, lower)| upper == '2' ? lower : upper }
      end

      def count_of(char)
        count_lookup[char]
      end

      def count_lookup
        @count_lookup ||= @chars.each_with_object(Hash.new { |h, k| h[k] = 0 }) do |char, hash|
          hash[char] += 1
        end
      end
    end
  end
end

