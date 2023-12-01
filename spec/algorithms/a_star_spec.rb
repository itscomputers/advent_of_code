require "algorithms/a_star"
require "data_structures/graph"

describe Algorithms::AStar do
  #       2           3           5             9
  #  a   --->    b   --->    c   --->    d    <----    f
  #  |           |           |
  #  | 20        | 10        | 4
  #  |           v           |
  #  -------->   e   <--------

  let(:graph) do
    DataStructures::Graph.new.tap do |graph|
      [
        [:a, :b, 2],
        [:a, :e, 20],
        [:b, :c, 3],
        [:b, :e, 10],
        [:c, :d, 5],
        [:c, :e, 4],
        [:f, :d, 9],
      ].each do |(source, target, weight)|
        graph.add_edge(source, target, weight: weight)
      end
    end
  end

  let(:expected_paths) { {
    a: [:a],
    b: [:a, :b],
    c: [:a, :b, :c],
    d: [:a, :b, :c, :d],
    e: [:a, :b, :c, :e],
  } }

  let(:expected_distances) { {a: 0, b: 2, c: 5, d: 10, e: 9} }

  let(:djikstra) { described_class.new(graph, source: :a) }

  let(:path) { djikstra.get_path(target: target) }
  let(:distance) { djikstra.get_distance(target: target) }
  before { djikstra.search(target: target) }

  [:a, :b, :c, :d, :e].each do |_target|
    context "of #{_target}" do
      let(:target) { _target }
      it "gives the expected path" do
        expect(path).to eq expected_paths[_target]
        expect(distance).to eq expected_distances[_target]
      end
    end
  end

  context "of f" do
    let(:target) { :f }
    it "has no path" do
      expect(path).to be_nil
      expect(distance).to be_nil
    end
  end

  describe ".get_shortest_path" do
    subject { described_class.get_shortest_path(graph, :a, target) }

    [:a, :b, :c, :d, :e, :f].each do |_target|
      context "of #{_target}" do
        let(:target) { _target }

        if _target == :f
          it { is_expected.to be_nil }
        else
          it { is_expected.to eq expected_paths[_target] }
        end
      end
    end
  end

  describe ".get_distance" do
    subject { described_class.get_distance(graph, :a, target) }

    [:a, :b, :c, :d, :e, :f].each do |_target|
      context "of #{_target}" do
        let(:target) { _target }

        if _target == :f
          it { is_expected.to be_nil }
        else
          it { is_expected.to eq expected_distances[_target] }
        end
      end
    end
  end

  describe ".connected?" do
    subject { described_class.connected?(graph, :a, target) }

    [:a, :b, :c, :d, :e, :f].each do |_target|
      context "to #{_target}" do
        let(:target) { _target }
        it { is_expected.to be _target != :f }
      end
    end
  end
end
