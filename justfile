setup year day:
  touch lib/year{{year}}/day{{day}}.rb
  touch lib/year{{year}}/inputs/{{day}}.txt
  touch spec/year{{year}}/day{{day}}_spec.rb

test year:
  rspec spec/year{{year}}

open year day:
  tmux split-window -d -p20 \; split-window -h -d "vim spec/year{{year}}/day{{day}}_spec.rb"
  vim lib/year{{year}}/day{{day}}.rb

