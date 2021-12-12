require "solver"
require "point"
require "set"

module Year2021
  class Day11 < Solver
    def solve(part:)
      case part
      when 1 then octopus_tracker.track(100).flash_count
      when 2 then octopus_tracker.track_simultaneous.step_count
      end
    end

    def grid
      Grid.parse(lines, as: :hash) { |_, ch| ch.to_i }
    end

    def octopus_tracker
      @octopus_tracker ||= OctopusTracker.new(grid)
    end

    class OctopusTracker
      attr_reader :flash_count, :step_count

      def initialize(grid)
        @grid = grid
        @step_count = 0
        @flash_count = 0
      end

      def track(steps)
        steps.times { step }
        self
      end

      def track_simultaneous
        step until @simultaneous
        self
      end

      def step
        step =  Step.new(@grid).stabilize
        @grid = step.grid
        @flash_count += step.flashes.count
        @simultaneous = true if step.flashes.count == @grid.size
        @step_count += 1
        self
      end

      def display
        Grid.display(@grid, type: :hash)
      end

      class Step
        attr_reader :grid, :flashes

        def initialize(grid)
          @grid = grid.transform_values { |value| value + 1 }
          @flashes = Set.new([])
          @stable = false
        end

        def stabilize
          advance until @stable
          @flashes.each do |point|
            @grid[point] = 0
          end
          self
        end

        def advance
          new_flashes = @grid.select { |point, value| !@flashes.include?(point) && value > 9 }
          @stable = true if new_flashes.empty?
          new_flashes.keys.each do |point|
            Point.neighbors_of(point, strict: false).each do |neighbor|
              @grid[neighbor] += 1 if @grid.key?(neighbor)
            end
            @flashes.add(point)
          end
        end
      end
    end
  end
end
