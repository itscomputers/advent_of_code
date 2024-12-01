class Range
  def overlap?(other)
    min <= other.max + 1 && max >= other.min - 1
  end

  def restricted_union(other)
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

  def union(others)
    Range.union([self, *others])
  end

  def union_v1(others)
    overlapping, independent = others.partition do |other|
      overlap?(other)
    end
    [
      *independent,
      overlapping.reduce(self) { |acc, other| acc.restricted_union(other) }
    ]
  end

  def subtract(other)
    [
      overlap?(other) ? nil : self,
      (min < other.min && other.min <= max + 1) ? (min..other.min - 1) : nil,
      (max > other.max && other.max >= min - 1) ? (other.max + 1..max) : nil
    ].compact
  end

  def self.union(ranges)
    return [] if ranges.empty?
    range, *others = ranges
    overlapping, independent = union(others).partition do |other|
      range.overlap?(other)
    end
    [
      overlapping.reduce(range) { |acc, other| acc.restricted_union(other) },
      *independent
    ]
  end
end
