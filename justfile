setup year day:
  touch lib/year{{year}}/day{{day}}.rb
  touch lib/year{{year}}/inputs/{{day}}.txt
  touch spec/year{{year}}/day{{day}}_spec.rb

test_all year:
  rspec spec/year{{year}}

test year day:
  rspec spec/year{{year}}/day{{day}}_spec.rb

open year day:
  tmux split-window -d -p20 \; split-window -h -d "vim spec/year{{year}}/day{{day}}_spec.rb"
  vim lib/year{{year}}/day{{day}}.rb

solve year day:
  ruby -I lib lib/advent.rb {{year}} {{day}}

save_input year day input:
  echo "{{input}}" > lib/year{{year}}/inputs/{{day}}.txt
