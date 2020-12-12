class Point < Struct.new(:x, :y)
  def inspect
    "(#{x}, #{y})"
  end

  def +(other)
    Point.new x + other.x, y + other.y
  end

  def -(other)
    Point.new x - other.x, y - other.y
  end

  def *(integer)
    Point.new x * integer, y * integer
  end

  def to_a
    [x, y]
  end

  def norm
    to_a.map(&:abs).sum
  end

  def euclidean_norm
    to_a.map { |t| t**2 }.sum
  end

  def rotate_clockwise_90
    Point.new -y, x
  end

  def rotate_counter_clockwise_90
    Point.new y, -x
  end
end

