YEAR, DAY, PART = ARGV

require "year#{YEAR}/day#{DAY}"

SOLVER = Object.const_get("Year#{YEAR}::Day#{DAY.to_i < 10 ? "0#{DAY.to_i}" : DAY}").new

def output(part:)
  "  part #{part}: #{SOLVER.solve(part: part)}"
end

if PART
  puts output(part: PART.to_i)
else
  puts [1, 2].map { |part| output(part: part) }.join("\n")
end

