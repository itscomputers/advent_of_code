require 'vector'

class Point < Struct.new(:x, :y)
  def inspect
    "(#{x}, #{y})"
  end

  def +(other)
    Point.new *Vector.add(to_a, other.to_a)
  end

  def -(other)
    Point.new *Vector.subtract(to_a, other.to_a)
  end

  def *(integer)
    Point.new *Vector.scale(to_a, integer)
  end

  def to_a
    [x, y]
  end

  def norm
    Vector.norm to_a
  end

  def rotate(direction)
    case direction
    when :cw then Point.new(-y, x)
    when :ccw then Point.new(y, -x)
    end
  end
end

