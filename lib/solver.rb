class Solver
  def file_name
    match = /Year(?<year>\d{4})::Day(?<day>\d{2})/.match self.class.to_s
    "lib/year#{match[:year]}/inputs/#{match[:day]}.txt"
  end

  def raw_input
    @raw_input ||= File.read(file_name)
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

