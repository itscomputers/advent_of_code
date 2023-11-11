require "algorithms/bfs"
require "data_structures/graph"

describe Algorithms::BFS do
  #  a   --->    b   --->    c   --->    d    <---    f
  #  |           |           |
  #  |           |           |
  #  |           v           |
  #  -------->   e   <--------

  let(:graph) do
    DataStructures::Graph.new.tap do |graph|
      [
        [:a, :b],
        [:a, :e],
        [:b, :c],
        [:b, :e],
        [:c, :d],
        [:c, :e],
        [:f, :d],
      ].each do |(source, target)|
        graph.add_edge(source, target)
      end
    end
  end

  let(:expected_paths) { {
    a: [:a],
    b: [:a, :b],
    c: [:a, :b, :c],
    d: [:a, :b, :c, :d],
    e: [:a, :e],
  } }

  let(:bfs) { described_class.new(graph, source: :a) }

  describe "given a target" do
    let(:path) { bfs.get_path(target: target) }
    let(:distance) { bfs.get_distance(target: target) }
    before { bfs.search(target: target) }

    [:a, :b, :c, :d, :e].each do |_target|
      context "of #{_target}" do
        let(:target) { _target }
        it "gives the expected path" do
          expect(path).to eq expected_paths[_target]
          expect(distance).to eq expected_paths[_target].size - 1
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
  end

  describe "no initial target" do
    before { bfs.search }

    it "has gives all shortest paths" do
      expected_paths.each do |target, expected_path|
        expect(bfs.get_path(target: target)).to eq expected_path
        expect(bfs.get_distance(target: target)).to eq expected_path.size - 1
      end
    end

    it "has no path for f" do
      expect(bfs.get_path(target: :f)).to be_nil
      expect(bfs.get_distance(target: :f)).to be_nil
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
          it { is_expected.to eq expected_paths[_target].size - 1 }
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
