require 'solver'

module Year2020
  class Day14 < Solver
    def solve(part:)
      decoder(part).new(lines).memory.values.sum
    end

    def decoder(part)
      case part
      when 1 then Decoder
      when 2 then DecoderV2
      end
    end

    class Decoder
      attr_reader :mask, :memory

      def self.mask_regex
        @mask_regex ||= Regexp.new /mask = (?<mask>[01X]+)/
      end

      def self.mem_regex
        @mem_regex ||= Regexp.new /mem\[(?<key>\d+)\] = (?<value>\d+)/
      end

      def initialize(input)
        @memory = Hash.new
        @mask = nil
        input.each(&method(:handle_row))
      end

      def handle_row(row)
        mask_match, memory_match = [:mask_regex, :mem_regex].map do |regex|
          self.class.send(regex).match row
        end

        if mask_match
          write_mask mask_match[:mask]
        elsif memory_match
          write_memory memory_match[:key].to_i, memory_match[:value].to_i
        end
      end

      def write_mask(string)
        @mask = string.split("").each_with_index.inject(Hash.new) do |hash, (char, index)|
          if char != "X"
            hash[35 - index] = char.to_i
          end
          hash
        end

        self
      end

      def write_memory(key, value)
        @memory[key] = @mask.reduce(value) do |acc, (key, value)|
          if value == 0 && acc & 2**key == 2**key
            acc ^ 2**key
          elsif value == 1 && acc & 2**key != 2**key
            acc ^ 2**key
          else
            acc
          end
        end
      end
    end

    class DecoderV2 < Decoder
      attr_reader :mask, :memory

      def initialize(input)
        @memory = Hash.new
        @mask = nil
        input.each(&method(:handle_row))
      end

      def floating
        (0..35).to_a - @mask.keys
      end

      def ones
        @mask.select { |k, v| v == 1 }.keys
      end

      def base(key)
        (((0..35).select { |e| key & 2**e == 2**e } | ones) - floating).sum { |e| 2**e }
      end

      def write_memory(key, value)
        floating.reduce([base(key)]) do |array, fl|
          [*array, *array.map { |k| k + 2**fl }]
        end.each do |address|
          @memory[address] = value
        end
      end
    end
  end
end

