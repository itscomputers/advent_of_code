require "solver"

module Year2023
  class Day15 < Solver
    def solve(part:)
      case part
      when 1 then sequence.map(&:hash).sum
      when 2 then HolidayHash.build(sequence).focusing_power
      else nil
      end
    end

    def sequence
      @seq ||= raw_input.chomp.split(",").map { |str| HolidayString.new(str) }
    end

    class HolidayString < String
      def hash
        each_byte.reduce(0) { |acc, byte| 17 * (acc + byte) % 256 }
      end
    end

    class HolidayHash
      Entry = Struct.new(:key, :value)

      def self.build(sequence)
        hash = new
        sequence.each do |str|
          if str.end_with?("-")
            hash.remove(HolidayString.new(str[...-1]))
          else
            key, value = str.split("=")
            hash.insert(HolidayString.new(key), value.to_i)
          end
        end
        hash
      end

      def initialize
        @data = []
      end

      def insert(key, value)
        entry = find_entry(key)
        if entry.nil?
          entries(key) << Entry.new(key, value)
        else
          entry.value = value
        end
      end

      def remove(key)
        entry = find_entry(key)
        entries(key).delete(entry) unless entry.nil?
      end

      def focusing_power
        @data.flat_map.with_index do |entries, box|
          (entries || []).map.with_index do |entry, index|
            (box + 1) * (index + 1) * entry.value
          end
        end.sum
      end

      private

      def entries(key)
        @data[key.hash] ||= []
      end

      def find_entry(key)
        entries(key).find { |entry| entry.key == key }
      end
    end
  end
end
