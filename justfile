test_all year:
  rspec spec/year{{year}}

test year day:
  rspec spec/year{{year}}/day{{day}}_spec.rb

open year day:
  tmux split-window -h -d "vim spec/year{{year}}/day{{day}}_spec.rb"\; split-window -d -t 1
  vim lib/year{{year}}/day{{day}}.rb

solve year day:
  ruby -I lib lib/advent.rb {{year}} {{day}}

save_input year day input:
  echo "{{input}}" > lib/year{{year}}/inputs/{{day}}.txt

setup year day:
  echo "require \"solver\"\n\nmodule Year{{year}}\n  class Day{{day}} < Solver\n    def solve(part:)\n    end\n  end\nend" > lib/year{{year}}/day{{day}}.rb
  echo "require \"year{{year}}/day{{day}}\"\n\ndescribe Year{{year}}::Day{{day}} do\n  let(:day) { Year{{year}}::Day{{day}}.new }\n  before do\n    allow(day).to receive(:lines).and_return []\n  end\nend" > spec/year{{year}}/day{{day}}_spec.rb
