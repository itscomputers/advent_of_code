class GridParser
  def initialize(string: nil, lines: nil)
    raise "provide `string` or `lines` but not both" unless string.nil? ^ lines.nil?

    @string = string
    @lines = lines
  end

  def lines
    @lines || @string.split("\n")
  end

  def parse_as_set(char:)
    lines.each_with_index.reduce(Set.new) do |set, (line, y)|
      line.chars.each_with_index do |ch, x|
        set.add([x, y]) if ch == char
      end
      set
    end
  end

  def parse_as_hash(&block)
    lines.each_with_index.reduce(Hash.new) do |hash, (line, y)|
      line.chars.each_with_index do |ch, x|
        hash[[x, y]] = block.nil? ? ch : block.call([x, y], ch)
      end
      hash
    end
  end
end

