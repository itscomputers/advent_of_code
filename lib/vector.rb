module Vector
  def self.add(array, other)
    array.zip(other).map(&:sum)
  end

  def self.subtract(array, other)
    add array, neg(other)
  end

  def self.dot(array, other)
    array.zip(other).sum { |coords| coords.reduce(&:*) }
  end

  def self.norm(array)
    array.sum { |coord| coord.abs }
  end

  def self.distance(array, other)
    norm subtract(array, other)
  end

  def self.scale(array, number)
    array.map { |coord| coord * number }
  end

  def self.apply(array, &block)
    array.map { |coord| block.call coord }
  end

  def self.neg(array)
    apply(array) { |coord| -coord }
  end
end

