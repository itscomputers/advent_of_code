require "grid"

class Solver
  def initialize(raw_input = nil)
    @raw_input = raw_input
  end

  def inspect
    "<Solver #{self.class}>"
  end

  def file_name
    match = /Year(?<year>\d{4})::Day(?<day>\d{2})/.match self.class.to_s
    "inputs/#{match[:year]}/#{match[:day]}.txt"
  end

  def raw_input
    @raw_input ||= File.read(file_name)
  end

  def lines
    @lines ||= raw_input.split("\n")
  end

  def chunks
    @chunks ||= raw_input.split("\n\n")
  end

  def parsed_lines
    @parsed_lines ||= lines.map(&method(:parse_line))
  end

  def parse_line(line)
    line
  end

  def solve(part:)
    case part
    when 1 then part_one
    when 2 then part_two
    end
  end

  def part_one
  end

  def part_two
  end
end
