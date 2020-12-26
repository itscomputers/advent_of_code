require 'modular'

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

