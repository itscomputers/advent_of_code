require "solver"

module Year2023
  class Day20 < Solver
    def solve(part:)
      case part
      when 1 then network.run(1000).pulse_factor
      when 2 then network.low_pulse_to_output
      else nil
      end
    end

    def network
      Network.build(lines)
    end

    class Network
      attr_reader :counter

      def self.build(lines)
        new.tap do |graph|
          lines = lines.map { |line| line.split(" -> ") }
          lines.each do |line|
            source, _ = line
            graph.add_node(Node.build(source))
          end
          lines.each do |line|
            source, targets = line
            targets.split(", ").each do |target|
              graph.add_edge(source, target)
            end
          end
        end
      end

      def initialize
        @nodes = Hash.new
        @counter = [0, 0]
        @iteration = 0
      end

      def pulse_factor
        @counter.reduce(:*)
      end

      def run(count)
        count.times do |iteration|
          if iteration > 0 && period_found?
            @counter = @counter.map { |val| val * count / iteration }
            break
          end
          press_button
        end
        self
      end

      def periods
        @periods ||= get_node(output.incoming.keys.first)
          .incoming
          .keys
          .map { |name| [name, nil] }
          .to_h
      end

      def period_found?
        flip_flops.all? { |flip_flop| flip_flop.state == 0 }
      end

      def low_pulse_to_output
        press_button until periods.values.none? { |val| val.nil? }
        periods.values.map { |val| val + 1 }.reduce(&:lcm)
      end

      def broadcaster
        get_node("broadcaster")
      end

      def output
        get_node("rx")
      end

      def press_button
        pulses = [Pulse.new(nil, broadcaster, 0)]
        until pulses.empty?
          pulse = pulses.shift
          @counter[pulse.value] += 1
          pulses = [*pulses, *pulse&.process]
          log_modules_of_interest(pulse)
        end
        @iteration += 1
        self
      end

      def log_modules_of_interest(pulse)
        return unless @nodes.key?("rx")
        if periods.key?(pulse.source&.name) && pulse.value == 1
          periods[pulse.source&.name] = @iteration
        end
      end

      def inspect
        @nodes.map(&:inspect).join("\n")
      end
      alias_method :to_s, :inspect

      def add_node(node)
        @nodes[node.name] = node
      end

      def flip_flops
        @flip_flops ||= @nodes.values.select { |node| node.is_a?(Node::FlipFlop) }
      end

      def get_node(name)
        if name.chr == "%" || name.chr == "&"
          @nodes[name[1..]]
        else
          @nodes[name] ||= Node.build(name)
        end
      end

      def add_edge(source, target)
        src = get_node(source)
        dst = get_node(target)
        src.add_neighbor(dst)
        if dst.is_a?(Node::Conjunction)
          dst.add_incoming(src)
        end
      end

      class Pulse < Struct.new(:source, :destination, :value)
        def process
          destination.relay(self)
        end
      end

      class Node < Struct.new(:name, :neighbors, :state)
        def self.build(str)
          if str.chr == "%"
            FlipFlop.new(str[1..], [], 0)
          elsif str.chr == "&"
            Conjunction.new(str[1..], [], nil)
          elsif str == "broadcaster"
            Broadcaster.new(str, [], 0)
          else
            Output.new(str, [], 0)
          end
        end

        def relay(pulse)
          raise NotImplementedError
        end

        def broadcast(value)
          neighbors.map { |neighbor| Pulse.new(self, neighbor, value) }
        end

        def inspect
          "<#{self.name}: #{self.class.to_s.split("::").last}, #{state}>"
        end
        alias_method :to_s, :inspect

        def add_neighbor(node)
          self.neighbors << node
        end

        class Broadcaster < Node
          def relay(pulse)
            broadcast(pulse.value)
          end
        end

        class FlipFlop < Node
          def relay(pulse)
            if pulse.value == 1
              []
            else
              self.state = 1 - self.state
              broadcast(state)
            end
          end
        end

        class Conjunction < Node
          def incoming
            @incoming ||= Hash.new
          end

          def add_incoming(node)
            incoming[node.name] = 0
          end

          def relay(pulse)
            incoming[pulse.source.name] = pulse.value
            if incoming.values.all? { |val| val == 1 }
              broadcast(0)
            else
              broadcast(1)
            end
          end
        end

        class Output < Conjunction
          def relay(pulse)
            []
          end
        end
      end
    end
  end
end
