Dir["lib/year****/day**.rb"].each(&method(:load))

YEAR, DAY, PART = ARGV
SOLVER = Object.const_get("Year#{YEAR}::Day#{DAY}").new

def output(part:)
  "  part #{part}: #{SOLVER.solve(part: part)}"
end

if PART
  puts output(part: PART.to_i)
else
  puts [1, 2].map { |part| output(part: part) }.join("\n")
end

