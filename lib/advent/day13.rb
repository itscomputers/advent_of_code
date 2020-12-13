require 'advent/day'

module Advent
  class Day13 < Advent::Day
    DAY = "13"

    def self.sanitized_input
      departure_string, bus_id_string = raw_input.split("\n")
      [departure_string, bus_id_string.split(",")]
    end

    def initialize(input)
      @earliest_departure = input.first.to_i
      @buses = input.last.map { |s| s == "x" ? nil : s.to_i }
    end

    def solve(part:)
      case part
      when 1 then earliest_bus_and_time.reduce(&:*)
      when 2 then ChineseRemainderTheorem.new(residues, moduli).solution
      end
    end

    def period
      @buses.compact.reduce(&:lcm)
    end

    def local_departure
      @earliest_departure % period
    end

    def buses_and_wait_times
      @buses.compact.map { |bus| [bus, bus - local_departure % bus] }
    end

    def earliest_bus_and_time
      buses_and_wait_times.min_by(&:last)
    end

    def moduli
      @buses.compact
    end

    def residues
      @buses.map.with_index { |bus, index| bus.nil? ? nil : -index }.compact
    end
  end
end

class ChineseRemainderTheorem
  def initialize(residues, moduli)
    @residues = residues
    @moduli = moduli
  end

  def product
    @product ||= @moduli.reduce(&:*)
  end

  def coeff(modulus)
    product / modulus * Modular.inverse(product / modulus, modulus) % product
  end

  def solution
    @residues.zip(@moduli).map { |(r, m)| coeff(m) * r % product }.sum % product
  end
end

module Modular
  def bezout(a, b)
    pairs = [[1, 0], [0, 1]]
    while b != 0
      q, r = a.divmod(b)
      a, b = b, r
      pairs = [pairs.last, pairs.transpose.map { |(u, v)| u - v * q }]
    end
    result = pairs.first
    a < 0 ? result.map { |u| -u } : result
  end

  def inverse(number, modulus)
    return unless modulus.gcd(number) == 1
    bezout(number, modulus).first % modulus
  end

  module_function :bezout, :inverse
end

