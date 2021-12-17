require "solver"

module Year2021
  class Day16 < Solver
    def solve(part:)
      case part
      when 1 then packet.version_sum
      when 2 then packet.value
      end
    end

    def outer_packet
      @outer_packet ||= OldPacket.for_hex(lines.first).process_subpackets
    end

    def packet
      @packet ||= Packet.new(BitStream.new(lines.first, type: :hex))
    end

    class BitStream
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

      def initialize(input, type: :binary)
        if type == :hex
          @stream = input.each_char.lazy.flat_map { |char| HEX_MAP[char].each_char.lazy }
        else
          @stream = input.each_char.lazy
        end
      end

      def take(bits=1)
        bits.times.map { @stream.next }.join
      end

      def peek
        @stream.peek
      end

      def read_int(bits=1)
        take(bits).to_i(2)
      end
    end

    class Packet
      attr_reader :bit_stream, :version, :type_id, :subpackets

      def initialize(bit_stream)
        @bit_stream = bit_stream
        @version = @bit_stream.read_int(3)
        @type_id = @bit_stream.read_int(3)
        @subpackets = []
        parse
      rescue StopIteration
        @version = -1
        @type_id = -1
        @subpackets = []
        @value = 0
      end

      def parse
        if @type_id == 4
          parse_literal
        else
          parse_length_type
        end
      end

      def parse_literal
        @value = LiteralPacketParser.new(@bit_stream).value
      end

      def parse_length_type
        length_type_id = @bit_stream.read_int
        @length = @bit_stream.read_int(15 - 4 * length_type_id)
        if length_type_id == 0
          parse_length_type_0
        else
          parse_length_type_1
        end
        self
      end

      def parse_length_type_0
        local_bit_stream = BitStream.new(@bit_stream.take(@length))
        loop do
          local_bit_stream.peek
          Packet.new(local_bit_stream).tap do |packet|
            @subpackets << packet if packet.valid?
          end
        rescue StopIteration
          break
        end
        self
      end

      def parse_length_type_1
        until @subpackets.size == @length
          Packet.new(@bit_stream).tap do |packet|
            @subpackets << packet if packet.valid?
          end
        end
        self
      end

      def valid?
        @version > -1
      end

      def version_sum
        @version + @subpackets.sum(&:version_sum)
      end

      def value
        @value ||= case @type_id
        when 0 then @subpackets.sum(&:value)
        when 1 then @subpackets.map(&:value).reduce(1) { |acc, value| acc * value }
        when 2 then @subpackets.min_by(&:value).value
        when 3 then @subpackets.max_by(&:value).value
        when 5 then binary_operator(:>)
        when 6 then binary_operator(:<)
        when 7 then binary_operator(:==)
        end
      end

      def binary_operator(operator)
        @subpackets.first.value.send(operator, @subpackets.last.value) ? 1 : 0
      end
    end

    class LiteralPacketParser
      def initialize(bit_stream)
        @bit_stream = bit_stream
      end

      def value
        return @value unless @value.nil?
        values = []
        values << @bit_stream.take(4) while @bit_stream.read_int == 1
        values << @bit_stream.take(4)
        @value = values.join.to_i(2)
      end
    end

    class OperatorPacketParser
      def initialize(bit_stream)
        bit_stream = bit_stream
        length_type_id = bit_stream.read_int
        length = bit_stream.read_int(15 - 4 * length_type_id)
        sub_class = length_type_id == 0 ? Type0Parser : Type1Parser
        @sub_parser = sub_class.new(bit_stream, length)
      end

      def subpackets
        @sub_parser.subpackets
      end

      class Type0Parser
        def initialize(bit_stream, length)
          @bit_stream = BitStream.new(bit_stream.take(length))
        end

        def subpackets
          return @subpackets unless @subpackets.nil?
          @subpackets = []
          loop do
            @bit_stream.peek
            Packet.new(@bit_stream).tap do |packet|
              @subpackets << packet if packet.valid?
            end
          rescue StopIteration
            break
          end
        end
      end

      class Type1Parser
        def initialize(bit_stream, length)
          @bit_stream = bit_stream
          @length = length
        end

        def subpackets
          @subpackets ||= @length.times.map do
            Packet.new(@bit_stream)
          end
        end
      end
    end


    class OldPacket
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

    class EmptyPacket < OldPacket
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

    class LiteralPacket < OldPacket
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

    class OperatorPacket < OldPacket
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
        OldPacket.for_binary(leftover)
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
