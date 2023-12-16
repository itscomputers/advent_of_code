require "solver"

module Year2023
  class Day14 < Solver
    def solve(part:)
      case part
      when 1 then platform.tilt(:north).total_load
      when 2 then platform.perform_cycles(1000000000).total_load
      else nil
      end
    end

    def platform
      Platform.build(lines)
    end

    class Platform
      def self.build(lines)
        new(
          Grid.parse(lines, as: :set) { "O" },
          Grid.parse(lines, as: :set) { "#" },
          lines.first&.length - 1,
          lines.size - 1,
        )
      end

      def initialize(rounded, cubed, x_max, y_max)
        @rounded = rounded
        @cubed = cubed
        @x_max = x_max
        @y_max = y_max
      end

      def total_load
        @rounded.map { |(_, y)| @y_max + 1 - y }.sum
      end

      def perform_cycles(count)
        rounded_states = RoundedStates.new(@rounded)
        loop do
          cycle
          break unless rounded_states.add?(@rounded)
        end
        @rounded = rounded_states.after(cycle: count)
        self
      end

      def cycle
        [:north, :west, :south, :east].each(&method(:tilt))
      end

      def rounded(direction)
        case direction
        when :north then rounded_by_col
        when :west then rounded_by_row
        when :south then rounded_by_col.reverse
        when :east then rounded_by_row.reverse
        else []
        end
      end

      def tilt(direction)
        rounded(direction).each do |rock|
          @rounded.delete(rock)
          @rounded.add(send("move_#{direction}", rock))
        end
        reset_cache
        self
      end

      def rounded_by_col
        (0..@x_max).flat_map do |x|
          column(x, @rounded).map do |y|
            [x, y]
          end
        end
      end

      def rounded_by_row
        (0..@y_max).flat_map do |y|
          row(y, @rounded).map do |x|
            [x, y]
          end
        end
      end

      def between_rows(rock)
        cubed_column(rock.first).each_cons(2).find do |(y1, y2)|
          rock.last.between?(y1, y2)
        end || [-1, @y_max + 1]
      end

      def between_columns(rock)
        cubed_row(rock.last).each_cons(2).find do |(x1, x2)|
          rock.first.between?(x1, x2)
        end || [-1, @x_max + 1]
      end

      def move_north(rock)
        y = between_rows(rock).first
        [rock.first, y + 1].tap(&method(:add_to_column))
      end

      def move_south(rock)
        y = between_rows(rock).last
        [rock.first, y - 1].tap(&method(:add_to_column))
      end

      def move_west(rock)
        x = between_columns(rock).first
        [x + 1, rock.last].tap(&method(:add_to_row))
      end

      def move_east(rock)
        x = between_columns(rock).last
        [x - 1, rock.last].tap(&method(:add_to_row))
      end

      def column(x, set)
        set.select { |rock| rock.first == x }.map(&:last).sort
      end

      def row(y, set)
        set.select { |rock| rock.last == y }.map(&:first).sort
      end

      def cubed_column(x)
        @cubed_column ||= Hash.new
        @cubed_column[x] ||= [-1, *column(x, @cubed), @y_max + 1]
      end

      def cubed_row(y)
        @cubed_row ||= Hash.new
        @cubed_row[y] ||= [-1, *row(y, @cubed), @x_max + 1]
      end

      def add_to_column(rock)
        x, y = rock
        @cubed_column[x] = [y, *@cubed_column[x]].sort
      end

      def add_to_row(rock)
        x, y = rock
        @cubed_row[y] = [x, *@cubed_row[y]].sort
      end

      def reset_cache
        @cubed_column = Hash.new
        @cubed_row = Hash.new
      end

      class RoundedStates
        def initialize(rounded)
          @states = [rounded.dup]
          @lookup = Set.new(@states)
          @offset = nil
          @period = nil
        end

        def add?(rounded)
          @lookup.add?(rounded.dup).tap do |bool|
            if bool
              @states << rounded.dup
            else
              @offset = @states.index(rounded.dup)
              @period = @states.size - (@offset || 0)
            end
          end
        end

        def after(cycle:)
          @states[@offset + (cycle - @offset) % @period]
        end
      end
    end
  end
end
