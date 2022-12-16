require "point"

class Circle < Struct.new(:center, :radius)
  def x
    center.first
  end

  def y
    center.last
  end

  def x_range(y_value: nil)
    return nil unless y_value.nil? || y_range.include?(y_value)
    offset = y_value.nil? ? radius : radius - (y - y_value).abs
    (x - offset..x + offset)
  end

  def y_range(x_value: nil)
    return nil unless x_value.nil? || x_range.include?(x_value)
    offset = x_value.nil? ? radius : radius - (x - x_value).abs
    (y - offset..y + offset)
  end

  def include?(point)
    Point.distance(center, point) <= radius
  end

  def interior?(point)
    Point.distance(center, point) < radius
  end

  def border?(point)
    Point.distance(center, point) == radius
  end

  def border_points
    (-radius..radius).flat_map do |offset|
      [
        [x + offset, y + radius - offset.abs],
        [x + offset, y - radius + offset.abs],
      ].uniq
    end
  end

  def horizon_points
    Circle.new(center, radius + 1).border_points
  end
end
