require "solver"

module Year2021
  class Day16 < Solver
    def solve(part:)
      case part
      when 1 then outer_packet.version_sum
      when 2 then outer_packet.value
      end
    end

    def outer_packet
      @outer_packet ||= Packet.for_hex(lines.first).process_subpackets
    end

    class Packet
      attr_reader :binary, :version, :type_id, :subpackets

      HEX_MAP = {
        "0" => "0000",
        "1" => "0001",
        "2" => "0010",
        "3" => "0011",
        "4" => "0100",
        "5" => "0101",
        "6" => "0110",
        "7" => "0111",
        "8" => "1000",
        "9" => "1001",
        "A" => "1010",
        "B" => "1011",
        "C" => "1100",
        "D" => "1101",
        "E" => "1110",
        "F" => "1111",
      }

      def self.for_hex(hex)
        for_binary(hex.chars.map { |char| HEX_MAP[char] }.join)
      end

      def self.for_binary(binary)
        return EmptyPacket.new(binary) if binary.chars.uniq == ["0"]

        version = binary.slice(0, 3).to_i(2)
        type_id = binary.slice(3, 3).to_i(2)
        params = [binary, version, type_id]

        return LiteralPacket.new(*params) if type_id == 4
        OperatorPacket.new(*params)
      end

      def inspect
        [
          "<",
          self.class.to_s.split("::").last ,
          " #{@type_id}->#{value}",
          subpackets.empty? ? nil : " (#{subpackets.map(&:inspect).join(", ")})",
          ">"
        ].compact.join
      end

      def version_sum
        (@version + subpackets.sum(&:version_sum))
      end

      def process_subpackets
        self
      end
    end

    class EmptyPacket < Packet
      def initialize(binary)
        @binary = binary
        @version = 0
        @subpackets = []
      end

      def leftover
        @binary
      end

      def value
        0
      end
    end

    class LiteralPacket < Packet
      def initialize(binary, version, type_id)
        @binary = binary
        @version = version
        @type_id = type_id
        @subpackets = []
      end

      def first_groups
        @first_groups ||= @binary.chars.drop(6).each_slice(5).take_while { |group| group.first == "1" }.map(&:join)
      end

      def last_group_index
        6 + first_groups.size * 5
      end

      def last_group
        @binary.slice(last_group_index, 5)
      end

      def leftover
        @binary.chars.drop(last_group_index + 5).join
      end

      def groups
        [*first_groups, last_group]
      end

      def value
        @value ||= groups.map { |group| group.slice(1, 4) }.join.to_i(2)
      end
    end

    class OperatorPacket < Packet
      def initialize(binary, version, type_id)
        @binary = binary
        @version = version
        @type_id = type_id
        @subpackets = []
      end

      def value
        @value ||= case @type_id
        when 0 then subpackets.sum(&:value)
        when 1 then subpackets.map(&:value).reduce(1) { |acc, value| acc * value }
        when 2 then subpackets.min_by(&:value).value
        when 3 then subpackets.max_by(&:value).value
        when 5 then binary_operator(:>)
        when 6 then binary_operator(:<)
        when 7 then binary_operator(:==)
        end
      end

      def length_type_id
        @binary[6].to_i
      end

      def bit_field_length
        15 - 4 * length_type_id
      end

      def bit_field
        @binary.slice(7, bit_field_length)
      end

      def length
        @length ||= bit_field.to_i(2)
      end

      def leftover
        @leftover ||= @binary.chars.drop(7 + bit_field_length).join
      end

      def subpacket
        Packet.for_binary(leftover)
      end

      def process_subpacket
        subpacket.process_subpackets.tap do |packet|
          @subpackets << packet
          @leftover = packet.leftover
        end
        self
      end

      def process_subpackets
        process_subpacket until terminated?
        self
      end

      def terminated?
        @terminated ||= length_type_id == 0 ?  leftover.chars.uniq == ["0"] : @subpackets.size == length
      end

      def binary_operator(operator)
        subpackets.first.value.send(operator, subpackets.last.value) ? 1 : 0
      end
    end
  end
end
