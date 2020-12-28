require 'solver'
require 'vector'

module Year2019
  class Day12 < Solver
    def part_one
      System.new(moons).after(generations: generations).total_energy
    end

    def part_two
      System.new(moons).period
    end

    def moons
      parsed_lines
    end

    def generations
      1000
    end

    def parse_line(line)
      Moon.new(
        position_regex.match(line)[1..3].map(&:to_i),
        [0, 0, 0]
      )
    end

    def position_regex
      @position_regex ||= /\<x=(\-?\d+), y=(\-?\d+), z=(\-?\d+)\>/
    end

    class System
      def initialize(moons)
        @gravitons = Graviton.from moons
      end

      def moons
        Moon.from @gravitons
      end

      def advance
        @gravitons.each(&:apply)
        self
      end

      def after(generations:)
        generations.times { advance }
        self
      end

      def total_energy
        moons.sum(&:total_energy)
      end

      def period
        @gravitons.map(&:period).reduce(&:lcm)
      end
    end

    class Moon < Struct.new(:position, :velocity)
      def self.from(gravitons)
        positions = gravitons.map(&:positions).transpose
        velocities = gravitons.map(&:velocities).transpose
        positions.zip(velocities).map { |(pos, vel)| Moon.new pos, vel }
      end

      def potential_energy
        Vector.norm position
      end

      def kinetic_energy
        Vector.norm velocity
      end

      def total_energy
        potential_energy * kinetic_energy
      end
    end

    class Graviton
      attr_reader :positions, :velocities

      def self.from(moons)
        positions = moons.map(&:position).transpose
        velocities = moons.map(&:velocity).transpose
        positions.zip(velocities).map { |(pos, vel)| Graviton.new pos, vel }
      end

      def initialize(positions, velocities)
        @positions = positions
        @velocities = velocities
        @step = 0
      end

      def velocity_offsets
        @positions.map do |position|
          above = @positions.count { |other| position < other }
          below = @positions.count { |other| position > other }
          above - below
        end
      end

      def update_velocities
        @velocities = Vector.add @velocities, velocity_offsets
      end

      def update_positions
        @positions = Vector.add @positions, @velocities
      end

      def apply
        update_velocities
        update_positions
        @step += 1
      end

      def period
        apply
        apply until @velocities.all?(0)
        2 * @step
      end
    end
  end
end

