require 'advent/day'

module Advent
  class Day25 < Advent::Day
    DAY = "25"

    def self.sanitized_input
      raw_input.split("\n").map(&:to_i)
    end

    def self.options
      { :base => 7, :modulus => 20201227 }
    end

    def initialize(input, base:, modulus:)
      @card_public_key, @door_public_key = input
      @base = base
      @modulus = modulus
    end

    def solve(part:)
      case part
      when 1 then encryption_key
      end
    end

    def card_loop_size
      @card_loop_size ||= LoopSizeSearch.new(@card_public_key, @base, @modulus).search
    end

    def door_loop_size
      @door_loop_size ||= LoopSizeSearch.new(@door_public_key, @base, @modulus).search
    end

    def encrypt(number, loop_size)
      Modular.power(number, loop_size, @modulus)
    end

    def encryption_key
      encrypt(@door_public_key, card_loop_size).tap do |key|
        #raise "incompatible" unless key == encrypt(@card_public_key, door_loop_size)
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

    class Modular
      def self.power(number, exponent, modulus)
        return 1 if exponent == 0
        return number % modulus if exponent == 1
        return number * number % modulus if exponent == 2
        return power(power(number, exponent/2, modulus), 2, modulus) if exponent % 2 == 0
        number * power(number, exponent-1, modulus) % modulus
      end
    end
  end
end

