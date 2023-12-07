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

  def subtract(other)
    [
      overlap?(other) ? nil : self,
      min < other.min && other.min <= max + 1 ? (min..other.min-1) : nil,
      max > other.max && other.max >= min - 1 ? (other.max+1..max) : nil,
    ].compact
  end
end
