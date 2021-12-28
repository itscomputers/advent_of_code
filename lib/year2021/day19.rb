require "set"
require "solver"
require "vector"

module Year2021
  class Day19 < Solver
    def solve(part:)
      beacons.size
    end

    def scanners
      @scanners ||= Scanner.from(raw_input)
    end

    def find_scanners
      @scanner_finder ||= ScannerFinder.new(scanners).find
    end

    def positions
      find_scanners
      scanners.map(&:position)
    end

    def beacons
      find_scanners
      scanners.flat_map do |scanner|
        scanner.beacons.map do |beacon|
          Vector.add(scanner.position, beacon)
        end
      end.uniq
    end

    class ScannerFinder
      def initialize(scanners)
        @scanners = scanners
        @scanners.first.position = [0, 0, 0]
      end

      def inspect
        "<ScannerFinder found: #{@scanners.map.with_index.reject { |p, i| p.position.nil? }.map(&:last)}>"
      end
      alias_method :to_s, :inspect

      def overlap
        unoriented, oriented = @scanners.partition { |scanner| scanner.position.nil? }
        oriented
          .product(unoriented)
          .map { |pair| Overlap.new(*pair) }
          .max_by { |overlap| overlap.common_abs_diffs.size }
      end

      def advance
        overlap.orient!
        self
      end

      def find
        advance until @scanners.all?(&:position)
        self
      end
    end

    class Scanner
      SCANNER_REGEX = /--- scanner \d+ ---/
      BEACON_REGEX = /([-]?\d+)/

      def self.from(raw_input)
        raw_input.split(SCANNER_REGEX).drop(1).map do |scanner_lines|
          new(
            scanner_lines
              .split("\n")
              .select { |line| BEACON_REGEX.match(line) }
              .map { |line| line.split(",").map(&:to_i) }
          )
        end
      end

      attr_reader :beacons
      attr_accessor :position

      def initialize(beacons)
        @beacons = beacons
      end

      def inspect
        "<Scanner beacons=#{@beacons.size}, position=#{@position}>"
      end
      alias_method :to_s, :inspect

      def diff_by_pair
        @diff_by_pair ||= beacons.combination(2).reduce(Hash.new) do |hash, pair|
          { **hash, pair => Vector.subtract(*pair) }
        end
      end

      def pair_by_diff
        @pair_by_diff ||= diff_by_pair.invert
      end

      def pair_for(diff)
        pair_by_diff[diff]
      end

      def diffs
        pair_by_diff.keys
      end

      def abs_diffs
        @abs_diffs ||= diffs.map { |diff| diff.map(&:abs).sort }.to_set
      end

      def orient_by!(reflective_permutation)
        @beacons = @beacons.map { |beacon| reflective_permutation.apply(beacon) }
        @diff_by_pair = nil
        @pair_by_diff = nil
        @abs_diffs = nil
      end
    end

    class Overlap
      attr_reader :oriented, :unoriented

      def initialize(oriented, unoriented)
        raise StandardError("#{oriented} is not oriented") if oriented.position.nil?
        @oriented = oriented
        @unoriented = unoriented
      end

      def inspect
        "<Overlap size=#{common_abs_diffs.size}>"
      end

      def common_abs_diffs
        @overlap_abs_diffs ||= @oriented.abs_diffs & @unoriented.abs_diffs
      end

      def oriented_diffs
        @oriented_diffs ||= @oriented.diffs.select { |diff| common_abs_diffs.include?(diff.map(&:abs).sort) }
      end

      def unoriented_diffs
        @unoriented_diffs ||= @unoriented.diffs.select { |diff| common_abs_diffs.include?(diff.map(&:abs).sort) }
      end

      def reflective_permutation_for(unoriented_diff)
        oriented_diff = oriented_diffs.find { |diff| diff.map(&:abs).sort == unoriented_diff.map(&:abs).sort }
        ReflectivePermutation.for(oriented_diff, unoriented_diff)
      end

      def reflective_permutations
        @reflective_permutations ||= unoriented_diffs.reduce(Hash.new { |h, k| h[k] = [] }) do |hash, diff|
          hash[reflective_permutation_for(diff)] << diff
          hash
        end.tap { |hash| puts hash.transform_values(&:size) }
      end

      def reflective_permutation
        reflective_permutations.keys.find { |rp| rp.reflection == 1 }.tap { |rp| return rp unless rp.nil? }
        @reflective_permutation ||= reflective_permutations
          .select { |_key, value| value.size > 30 }
          .min_by { |_key, value| value.size }
          .first
      end

      def orient!
        @unoriented.orient_by!(reflective_permutation)

        relative_position = (@oriented.diffs & @unoriented.diffs).flat_map do |diff|
          @oriented.pair_for(diff).zip(@unoriented.pair_for(diff)).map do |pair|
            Vector.subtract(*pair)
          end
        end.uniq.first
        @unoriented.position = Vector.add(@oriented.position, relative_position)

        @unoriented
      end
    end

    class ReflectivePermutation
      PERMUTATION = {
        :e => [0, 1, 2],
        :r => [1, 2, 0],
        :s => [2, 0, 1],
        :a => [0, 2, 1],
        :b => [2, 1, 0],
        :c => [1, 0, 2],
      }

      REFLECTION = {
        0 => [1, 1, 1],
        1 => [-1, 1, 1],
        2 => [1, -1, 1],
        3 => [-1, -1, 1],
        4 => [1, 1, -1],
        5 => [-1, 1, -1],
        6 => [1, -1, -1],
        7 => [-1, -1, -1],
      }

      def self.apply_permutation(array, permutation)
        PERMUTATION[permutation].map { |idx| array[idx] }
      end

      def self.apply_reflection(array, reflection)
        REFLECTION[reflection].zip(array).map { |sgn, item| sgn * item }
      end

      def self.which_permutation?(array, other)
        PERMUTATION.keys.find { |permutation| apply_permutation(other, permutation) == array }
      end

      def self.which_reflection?(array, other)
        REFLECTION.keys.find { |reflection| apply_reflection(other, reflection) == array }
      end

      def self.for(array, other)
        permutation = which_permutation?(array.map(&:abs), other.map(&:abs))
        return if permutation.nil?

        reflection = which_reflection?(
          array,
          apply_permutation(other, permutation),
        )

        new(permutation, reflection)
      end

      attr_reader :permutation, :reflection

      def initialize(permutation, reflection)
        @permutation = permutation
        @reflection = reflection
      end

      def inspect
        "<ReflectivePermutation #{@permutation}, #{@reflection}>"
      end

      def signature
        [@permutation, @reflection]
      end

      def apply(array)
        apply_reflection(apply_permutation(array))
      end

      def apply_permutation(array)
        self.class.apply_permutation(array, @permutation)
      end

      def apply_reflection(array)
        self.class.apply_reflection(array, @reflection)
      end

      def eql?(other)
        signature == other.signature
      end

      def ==(other)
        eql?(other)
      end

      def hash
        signature.hash
      end
    end
  end
end

