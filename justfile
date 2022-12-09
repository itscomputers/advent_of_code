console:
  irb -I lib

test_all year:
  rspec spec/year{{year}}

test year day:
  rspec spec/year{{year}}/day{{day}}_spec.rb

open year day:
  tmux split-window -h -d "vim spec/year{{year}}/day{{day}}_spec.rb"\; split-window -d -t 1
  vim lib/year{{year}}/day{{day}}.rb

solve year day:
  ruby -I lib lib/advent.rb {{year}} {{day}}

solve_part year day part:
  ruby -I lib lib/advent.rb {{year}} {{day}} {{part}}

save_input year day input:
  echo "{{input}}" > lib/year{{year}}/inputs/{{day}}.txt

setup year day: (_save_day year day) (_save_spec year day) (open year day)

_save_day year day:
  echo "require \"solver\"\n\nmodule Year{{year}}\n  class Day{{day}} < Solver\n    def solve(part:)\n    end\n  end\nend" > lib/year{{year}}/day{{day}}.rb

_save_spec year day:
  echo "require \"year{{year}}/day{{day}}\"\n\ndescribe Year{{year}}::Day{{day}} do\n let(:day) { Year{{year}}::Day{{day}}.new }\n  before do\n    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT\n\n    RAW_INPUT\n  end\nend" > spec/year{{year}}/day{{day}}_spec.rb
