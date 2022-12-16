class Range
  def overlap?(other)
    min, max = minmax
    omin, omax = other.minmax
    min <= omax + 1 && max >= omin - 1
  end

  def union(other)
    return nil unless overlap?(other)
    min = [self, other].map(&:min).min
    max = [self, other].map(&:max).max
    (min..max)
  end

  def intersection(other)
    return nil unless overlap?(other)
    min = [self, other].map(&:min).max
    max = [self, other].map(&:max).min
    return nil if min > max
    (min..max)
  end

  def unions(others)
    overlapping, independent = others.partition do |other|
      overlap?(other)
    end
    [
      *independent,
      overlapping.reduce(self) { |acc, other| acc.union(other) },
    ]
  end
end
