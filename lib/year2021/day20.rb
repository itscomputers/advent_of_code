require "solver"
require "grid"
require "point"

module Year2021
  class Day20 < Solver
    def solve(part:)
      case part
      when 2 then pixel_count(iteration: 50)
#     when 1 then pixel_count(iteration: 2)
      end
    end

    def image_enhancement
      @image_enhancement ||= ImageEnhancement.new(lines.first)
    end

    def grid
      @grid ||= Grid.parse(lines.drop(2), as: :hash)
    end

    def neighbors_of(point)
      [point, *Point.neighbors_of(point, strict: false)].sort_by(&:reverse)
    end

    def nine_bit_string(point)
      neighbors_of(point).map do |neighbor|
        grid[neighbor] || "."
      end.join
    end

    def expanded_points(buffer:)
      x0, x1 = grid.keys.map(&:first).minmax
      y0, y1 = grid.keys.map(&:last).minmax
      (x0-buffer..x1+buffer).to_a.product(
        (y0-buffer..y1+buffer).to_a
      )
    end

    def enhance!(buffer:)
      new_grid = expanded_points(buffer: buffer).reduce(Hash.new) do |hash, point|
        hash[point] = image_enhancement.enhance(nine_bit_string(point))
        hash
      end
      @grid = new_grid
      self
    end

    def pixel_count(iteration:)
      iteration.times { |i| enhance!(buffer: 2 * iteration + 1).tap { puts "iteration: #{i + 1}" } }
      grid.count do |point, value|
        point.all? { |t| t.between?(-iteration, 99 + iteration) } && value == "#"
      end
    end

    class ImageEnhancement
      def initialize(line)
        @chars = line.chars
      end

      def enhance(nine_bit_string)
        @chars[nine_bit_string.gsub(/[#\.]/, "#" => "1", "." => "0").to_i(2)]
      end
    end
  end
end
