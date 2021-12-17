require "solver"

module Year2021
  class Day16 < Solver
    def solve(part:)
      case part
      when 1 then packet.version_sum
      when 2 then packet.value
      end
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
        parse
      rescue StopIteration
        @version = -1
        @type_id = -1
        @subpackets = []
        @value = 0
      end

      def parse
        if @type_id == 4
          @value = LiteralPacketParser.new(@bit_stream).value
          @subpackets = []
        else
          @subpackets = OperatorPacketParser.new(@bit_stream).subpackets
        end
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
          @subpackets
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
  end
end
