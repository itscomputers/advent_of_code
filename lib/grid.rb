module Grid
  def self.parse(lines, as:, &block)
    case as.to_s
    when "set" then parse_as_set(lines, char: block.call)
    when "hash" then parse_as_hash(lines, block)
    end
  end

  def self.display(input, type:, **sub)
    result = send :"display_#{type}", input
    sub.empty? ? result : result.gsub(/[#{sub.keys.join("")}]/, **sub)
  end

  #---------------------------
  # helper methods

  def self.parse_as_hash(lines, block)
    lines.each_with_index.each_with_object({}) do |(line, y), hash|
      line.chars.each_with_index do |ch, x|
        hash[[x, y]] = block.nil? ? ch : block.call([x, y], ch)
      end
    end
  end

  def self.parse_as_set(lines, char:)
    lines.each_with_index.each_with_object(Set.new) do |(line, y), set|
      line.chars.each_with_index do |ch, x|
        set.add([x, y]) if ch == char
      end
    end
  end

  def self.display_array(array)
    y_range(array).map do |y|
      x_range(array).map do |x|
        array.include?([x, y]) ? 1 : 0
      end.join("")
    end.join("\n")
  end

  def self.display_set(set)
    display_array(set)
  end

  def self.display_hash(hash)
    y_range(hash.keys).map do |y|
      x_range(hash.keys).map do |x|
        hash.fetch [x, y], " "
      end.join("")
    end.join("\n")
  end

  def self.display_rows(rows)
    rows.map { |row| row.join("") }.join("\n")
  end

  def self.range_from(numbers)
    Range.new(*numbers.minmax)
  end

  def self.y_range(points)
    range_from points.map(&:last)
  end

  def self.x_range(points)
    range_from points.map(&:first)
  end

  def self.dimensions(points)
    [
      x_range(points).size,
      y_range(points).size
    ]
  end
end
