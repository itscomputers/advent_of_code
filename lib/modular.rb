module Modular
  def self.bezout(a, b)
    pairs = [[1, 0], [0, 1]]
    while b != 0
      q, r = a.divmod(b)
      a, b = b, r
      pairs = [pairs.last, pairs.transpose.map { |(u, v)| u - v * q }]
    end
    result = pairs.first
    a < 0 ? result.map { |u| -u } : result
  end

  def self.inverse(number, modulus)
    return unless modulus.gcd(number) == 1
    bezout(number, modulus).first % modulus
  end

  def self.power(number, exponent, modulus)
    return power(inverse(number, modulus), -exponent, modulus) if exponent < 0
    return 1 if exponent == 0
    return number % modulus if exponent == 1
    return number * number % modulus if exponent == 2
    return power(power(number, exponent/2, modulus), 2, modulus) if exponent % 2 == 0
    number * power(number, exponent-1, modulus) % modulus
  end
end

