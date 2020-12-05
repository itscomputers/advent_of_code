Dir["lib/advent/day**.rb"].each(&method(:load))

module Advent
  class Solver
    def initialize(day_number)
      @day_number = day_number
    end

    def day
      @day ||= Advent.class_eval("Day#{@day_number}").build
    end

    def solve(part:)
      day.solve(part: part)
    end
  end
end

SOLVER = Advent::Solver.new("#{ARGV.first}")

def output(part:)
  "  part #{part}: #{SOLVER.solve(part: part)}"
end

if ARGV.size > 1
  puts output(part: ARGV[1].to_i)
elsif ARGV.size == 1
  puts [1, 2].map { |part| output(part: part) }.join("\n")
end

