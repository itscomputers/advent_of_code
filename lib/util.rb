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
end

