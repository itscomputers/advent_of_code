require 'advent/day'

module Advent
  class Day20 < Advent::Day
    DAY = "20"

    def self.sanitized_input
      raw_input.split("\n\n")
    end

    def initialize(input)
      @tile_strings = input
    end

    def solve(part:)
      case part
      when 1 then corner_ids.reduce(&:*)
      when 2 then rough_water_count
      end
    end

    def image_assembler
      ImageAssembler.new(tile_lookup, corners).tap do
        log_matches
      end
    end

    def grid
      @grid ||= image_assembler.grid
    end

    def symmetries
      TileConfiguration.configurations.values
    end

    def rough_water_count
      symmetries.each do |symmetry|
        monster_search = MonsterSearch.new(
          GridOperations.send(symmetry, grid, grid.size)
        )

        if monster_search.monster_count > 0
          return monster_search.rough_water_count
        end
      end
    end

    def corners
      corner_ids.map { |id| tile_lookup[id] }
    end

    def corner_ids
      @corner_ids ||= border_lookup
        .values
        .select { |border| border.tiles.size == 1 }
        .group_by { |border| border.tiles.keys.first }
        .select { |_id, borders| borders.size == 4 }
        .keys
    end

    def tile_lookup
      @tile_lookup ||= @tile_strings.each_with_object(Hash.new) do |string, memo|
        rows = string.split("\n")
        id = /Tile (?<id>\d+):/.match(rows.first)[:id].to_i
        memo[id] = Tile.new(id, rows.drop(1))
      end
    end

    def border_lookup
      @border_lookup ||= tile_lookup.values
        .each_with_object(Hash.new) do |tile, memo|
          tile.borders.each do |border|
            memo[border] ||= Border.new(border)
            memo[border].add_tile tile
          end
      end
    end

    def log_matches
      border_lookup.values.each do |border|
        if border.tiles.size == 2
          tile_id, other_id = border.tiles.keys
          tile = tile_lookup[tile_id]
          other = tile_lookup[other_id]
          tile.add_match(
            border.tiles[tile_id],
            { other_id => border.tiles[other_id] }
          )
          other.add_match(
            border.tiles[other_id],
            { tile_id => border.tiles[tile_id] }
          )
        end
      end
    end

    class Tile
      attr_reader :id, :rows, :config

      def initialize(id, rows)
        @id = id
        @rows = rows
      end

      def inspect
        "<Tile #{@id} #{@config}>"
      end

      def size
        @rows.size
      end

      def borders
        border_label_lookup.keys
      end

      def match_edges
        matches.reject { |k, v| v.empty? }.keys.map(&:downcase).uniq
      end

      def determine_config(label, ref)
        @config = TileConfiguration.determine_from(label, ref)
      end

      def details_for(direction)
        return unless @config
        matches[@config[direction]]
      end

      def matches
        @matches ||= {
          :east => {},
          :north => {},
          :west => {},
          :south => {},
          :eAST => {},
          :nORTH => {},
          :wEST => {},
          :sOUTH => {},
        }
      end

      def add_match(label, tile_hash)
        @matches[label].merge! tile_hash
      end

      def border_label_lookup
        @border_lookup ||= matches.keys.map { |label| [send(label), label] }.to_h
      end

      def north
        @north ||= tree_indeces @rows.first.chars
      end

      def nORTH
        reverse north
      end

      def south
        @south ||= tree_indeces @rows.last.chars
      end

      def sOUTH
        reverse south
      end

      def east
        @east ||= tree_indeces @rows.map { |row| row.chars.last }
      end

      def eAST
        reverse east
      end

      def west
        @west ||= tree_indeces @rows.map { |row| row.chars.first }
      end

      def wEST
        reverse west
      end

      def tree_indeces(chars)
        chars.each_with_index.select { |char, _| char == "#" }.map(&:last)
      end

      def reverse(border)
        border.map { |index| size - index - 1 }.sort
      end
    end

    class Border
      attr_reader :tiles

      def initialize(indeces)
        @indeces = indeces
        @tiles = Hash.new
      end

      def add_tile(tile)
        @tiles[tile.id] = tile.border_label_lookup[@indeces]
      end
    end

    class TileConfiguration
      def self.rot(array, index)
        array.cycle.take(8).drop(index % 4).take(4)
      end

      def self.default
        [:north, :east, :south, :west]
      end

      def self.configurations
        {
          default => :rot_0,
          [:wEST, :north, :eAST, :south] => :rot_90,
          [:sOUTH, :wEST, :nORTH, :eAST] => :rot_180,
          [:east, :sOUTH, :west, :nORTH] => :rot_270,
          [:south, :eAST, :north, :wEST] => :ref_0,
          [:nORTH, :west, :sOUTH, :east] => :ref_90,
          [:eAST, :nORTH, :wEST, :sOUTH] => :ref_45,
          [:west, :south, :east, :north] => :ref_135,
        }
      end

      def self.determine_from(label, ref)
        default
          .zip(configurations.keys.find { |array| array[default.index(label)] == ref })
          .to_h
      end

      def self.grid_from(grid, size, config)
        GridOperations.send(
          configurations[config.slice(*default).values],
          grid,
          size,
        )
      end
    end

    class GridOperations
      def self.draw(grid)
        grid.map { |row| row.join("") }.join("\n")
      end

      def self.rot_0(grid, size)
        grid
      end

      def self.rot_90(grid, size)
        (0...size).map do |y|
          (0...size).map do |x|
            grid[size - x - 1][y]
          end
        end
      end

      def self.rot_180(grid, size)
        rot_90(
          rot_90(grid, size),
          size,
        )
      end

      def self.rot_270(grid, size)
        rot_90(
          rot_180(grid, size),
          size,
        )
      end

      def self.ref_0(grid, size)
        grid.reverse
      end

      def self.ref_45(grid, size)
        rot_90(
          ref_90(grid, size),
          size,
        )
      end

      def self.ref_90(grid, size)
        grid.map(&:reverse)
      end

      def self.ref_135(grid, size)
        rot_90(
          ref_0(grid, size),
          size,
        )
      end
    end

    class TilePresentation
      def initialize(tile)
        @tile = tile
      end

      def grid
        @grid ||= TileConfiguration.grid_from(
          @tile.rows.map(&:chars),
          @tile.size,
          @tile.config
        )[1...-1].map { |row| row[1...-1] }
      end
    end

    class ImageAssembler
      def initialize(tile_lookup, corners)
        @tile_lookup = tile_lookup
        @corners = corners
        @size = Math.sqrt(tile_lookup.size).to_i
      end

      def inspect
        "<ImageAssembler>"
      end

      def grid
        @grid ||= rows.map do |row|
          sub_grids = row.map do |tile|
            TilePresentation.new(tile).grid.tap do |sub_grid|
              @rows_per_sub_grid = sub_grid.size
            end
          end
          @rows_per_sub_grid.times.map do |index|
            sub_grids.flat_map { |sub_grid| sub_grid[index] }
          end
        end.flatten(1)
      end

      def rows
        @rows ||= (1...@size).reduce([top_row]) do |array, _|
          [*array, next_row(array.last)]
        end
      end

      def nw_corner
        @corners.find { |tile| tile.match_edges.sort == [:east, :south] }.tap do |corner|
          corner.determine_config :west, :west
        end
      end

      def top_row
        (1...@size).reduce([nw_corner]) do |array, _|
          [*array, tile_to_east(array.last)]
        end
      end

      def next_row(row)
        row.map { |tile| tile_to_south(tile) }
      end

      def tile_for(id)
        @tile_lookup[id]
      end

      def tile_to_east(tile)
        id, ref = tile.details_for(:east).to_a.first
        tile_for(id).tap do |tile|
          tile&.determine_config :west, ref
        end
      end

      def tile_to_south(tile)
        id, ref = tile.details_for(:south).to_a.first
        tile_for(id).tap do |tile|
          tile&.determine_config :north, ref
        end
      end
    end

    class MonsterSearch
      def initialize(grid)
        @grid = grid
      end

      def monster
        @monster ||= [
          "                  # ",
          "#    ##    ##    ###",
          " #  #  #  #  #  #   ",
        ].flat_map.with_index do |row, y|
          row
            .chars
            .each_with_index
            .select { |char, x| char == "#" }
            .map { |_char, x| [x, y] }
        end
      end

      def search_space
        [
          @grid.first.size - monster.map(&:first).max,
          @grid.size - monster.map(&:last).max,
        ]
      end

      def monster_at?(x, y)
        monster.all? do |(m_x, m_y)|
          @grid[y + m_y][x + m_x] == "#"
        end
      end

      def monster_count
        @monster_count ||= begin
          max_x, max_y = search_space
          (0...max_x).to_a.product((0...max_y).to_a).count do |(x, y)|
            monster_at?(x, y)
          end
        end
      end

      def rough_water_count
        @grid.flatten.count("#") - monster_count * monster.size
      end
    end
  end
end

