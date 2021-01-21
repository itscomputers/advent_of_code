require 'vector'

class Point < Struct.new(:x, :y)
  def self.rotate(array, direction)
    new(*array).rotate(direction).to_a
  end

  def self.distance(array, other)
    new(*array).distance(other)
  end

  def self.neighbors_of(array, strict: true)
    directions = [[0, 1], [0, -1], [1, 0], [-1, 0]]
    unless strict
      directions += [[1, 1], [1, -1], [-1, 1], [-1, -1]]
    end

    directions.map do |direction|
      (new(*array) + new(*direction)).to_a
    end
  end

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

  def distance(other)
    Vector.distance to_a, other.to_a
  end

  def rotate(direction)
    case direction
    when :cw then Point.new(-y, x)
    when :ccw then Point.new(y, -x)
    end
  end
end

