require 'solver'
require 'modular'

module Year2020
  class Day25 < Solver
    def ids
      [:card, :door]
    end

    def public_keys
      @public_keys ||= ids.zip(raw_input.split("\n").map(&:to_i)).to_h
    end

    def base
      7
    end

    def modulus
      20201227
    end

    def part_one
      encryptions.tap do |encryptions|
        raise "incompatible" unless encryptions.uniq.size == 1
      end.first
    end

    def private_keys
      @private_keys ||= ids.each_with_object(Hash.new) do |id, hash|
        hash[id] = LoopSizeSearch.new(public_keys[id], base, modulus).search
      end
    end

    def encryptions
      ids.zip(ids.reverse).map do |id, other|
        Modular.power public_keys[id], private_keys[other], modulus
      end
    end

    class LoopSizeSearch
      def initialize(number, base, modulus)
        @number = number
        @base = base
        @modulus = modulus
      end

      def search
        loop_size = 0
        subject = 1
        while subject != @number do
          loop_size += 1
          subject = subject * @base % @modulus
        end
        loop_size
      end
    end
  end
end

