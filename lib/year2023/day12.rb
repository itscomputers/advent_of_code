require "solver"

module Year2023
  class Day12 < Solver
    def solve(part:)
      case part
      when 1 then resolvers.map(&:resolve).map(&:count).sum
      when 2 then unfolded_resolvers.map(&:resolve).map(&:count).sum
      else nil
      end
    end

    def resolvers
      lines.map do |line|
        Resolver.new(Arrangement.build(string(line), sizes(line)))
      end
    end

    def unfolded_resolvers
      lines.map do |line|
        Resolver.new(Arrangement.unfold(string(line), sizes(line)))
      end
    end

    def string(line)
      line.split(" ").first
    end

    def sizes(line)
      line.split(" ").last.split(",").map(&:to_i)
    end


    class Resolver
      def initialize(arrangement)
        @terminal = []
        @queue = [arrangement.advance]
      end

      def resolve
        process_next until @queue.empty?
        self
      end

      def process_next
        arrangement = @queue.shift
        return self if arrangement.nil?
        return self if arrangement.invalid?
        @terminal << arrangement if arrangement.terminal?
        arrangement.split.each do |split|
          next if split.invalid?
          if split.terminal?
            @terminal << split
          else
            @queue << split
          end
        end
        self
      end

      def count
        @terminal.size
      end
    end

    class Arrangement < Struct.new(:string, :sizes, :index)
      def self.build(string, sizes)
        new(string, sizes, 0)
      end

      def self.unfold(string, sizes)
        new(
          5.times.map { string }.join("?"),
          5.times.flat_map { sizes },
          0,
        )
      end

      def inspect
        "<#{string}, #{sizes}, #{index}>"
      end
      alias_method :to_s, :inspect

      def terminal?
        sizes.empty? && slice_could_be_empty?
      end

      def invalid?
        @invalid ||
          (sizes.empty? && !slice_could_be_empty?) ||
          (!sizes.empty? && slice_is_empty?)
      end

      def can_split?
        char == "?"
      end

      def split
        %w(# .).map do |ch|
          Arrangement.new(string_with(ch), sizes, index).advance
        end.reject(&:invalid?)
      end

      def can_advance?
        !terminal? && !invalid? && !can_split?
      end

      def advance
        while can_advance?
          if char == "."
            self.index += slice.index(/[?#]/)
          else
            if prefix.chars.any? { |ch| ch == "." }
              @invalid = true
            elsif prefix.length < size
              @invalid = true
            elsif slice.length > size && slice[size] == "#"
              @invalid = true
            elsif slice.length == size
              self.index = string.length
              self.sizes = self.sizes.drop(1)
            else
              self.index += size + 1
              self.sizes = self.sizes.drop(1)
            end
          end
        end
        self
      end

      def char
        slice.chr
      end

      def slice
        index > string.length ? "" : string[index..]
      end

      def prefix
        slice[...size] || ""
      end

      def size
        sizes.first || 0
      end

      def slice_could_be_empty?
        slice.empty? || slice.chars.none? { |ch| ch == "#" }
      end

      def slice_is_empty?
        slice.empty? || slice.chars.all? { |ch| ch == "." }
      end

      def string_with(ch)
        (string[...index] || "") + ch + (slice[1..] || "")
      end
    end
  end
end
