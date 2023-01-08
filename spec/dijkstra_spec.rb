require "dijkstra"
require "graph"

describe Dijkstra do
  class TestGraph < BaseGraph
    def initialize(lookup)
      @lookup = lookup
    end

    def size
      @lookup.size
    end

    def neighbors(value)
      @lookup[value].keys
    end

    def distance(value, other)
      @lookup[value]&.dig(other)
    end
  end

  let(:lookup) { {
    "AA" => %w(DD II BB).map { |label| [label, 1] }.to_h,
    "BB" => %w(CC AA).map { |label| [label, 1] }.to_h,
    "CC" => %w(DD BB).map { |label| [label, 1] }.to_h,
    "DD" => %w(CC AA EE).map { |label| [label, 1] }.to_h,
    "EE" => %w(FF DD).map { |label| [label, 1] }.to_h,
    "FF" => %w(EE GG).map { |label| [label, 1] }.to_h,
    "GG" => %w(FF HH).map { |label| [label, 1] }.to_h,
    "HH" => %w(GG).map { |label| [label, 1] }.to_h,
    "II" => %w(AA JJ).map { |label| [label, 1] }.to_h,
    "JJ" => %w(II).map { |label| [label, 1] }.to_h,
  } }
  let(:graph) { TestGraph.new(lookup) }
  let(:targets) { %w(BB CC DD EE HH JJ) }
  let(:dijkstra) { described_class.new(graph, start, targets: targets) }

  describe "distance_lookup" do
    subject { dijkstra.execute.distances }

    {
      "AA" => {"BB" => 1, "CC" => 2, "DD" => 1, "EE" => 2, "HH" => 5, "JJ" => 2},
      "BB" => {"BB" => 0, "CC" => 1, "DD" => 2, "EE" => 3, "HH" => 6, "JJ" => 3},
      "CC" => {"BB" => 1, "CC" => 0, "DD" => 1, "EE" => 2, "HH" => 5, "JJ" => 4},
      "DD" => {"BB" => 2, "CC" => 1, "DD" => 0, "EE" => 1, "HH" => 4, "JJ" => 3},
      "EE" => {"BB" => 3, "CC" => 2, "DD" => 1, "EE" => 0, "HH" => 3, "JJ" => 4},
      "HH" => {"BB" => 6, "CC" => 5, "DD" => 4, "EE" => 3, "HH" => 0, "JJ" => 7},
      "JJ" => {"BB" => 3, "CC" => 4, "DD" => 3, "EE" => 4, "HH" => 7, "JJ" => 0},
    }.each do |label, distances|
      context "when start is #{label}" do
        let(:start) { label }
        it { is_expected.to eq distances }
      end
    end
  end
end
