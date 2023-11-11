require "algorithms/dfs"
require "data_structures/graph"

describe Algorithms::DFS do
  #     a   --->    b   --->    c   --->    d
  #     |           |           |
  #     |           |           |
  #     |           v           |
  #     -------->   e   <--------

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

  let(:dfs) { described_class.new(graph, source: :a) }

  describe "given a target" do
    let(:path) { dfs.get_path(target: target) }
    let(:distance) { dfs.get_distance(target: target) }
    before { dfs.search(target: target) }

    [:a, :b, :c, :d, :e].each do |_target|
      let(:target) { _target }

      context "of #{_target}" do
        it "gives a path to #{_target}" do
          expect(path.first).to eq :a
          expect(path.last).to eq target
          expect(distance).to eq path.size - 1
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
    before { dfs.search }

    it "has gives all shortest paths" do
      [:a, :b, :c, :d, :e].each do |target|
        path = dfs.get_path(target: target)
        expect(path.first).to eq :a
        expect(path.last).to eq target
        expect(dfs.get_distance(target: target)).to eq path.size - 1
      end
    end

    it "has no path for f" do
      expect(dfs.get_path(target: :f)).to be_nil
      expect(dfs.get_distance(target: :f)).to be_nil
    end
  end

  describe ".get_path" do
    subject { described_class.get_path(graph, :a, target) }

    [:a, :b, :c, :d, :e, :f].each do |_target|
      context "of #{_target}" do
        let(:target) { _target }

        if _target == :f
          it { is_expected.to be_nil }
        else
          it "starts at a" do
            expect(subject.first).to eq :a
          end

          it "ends at #{_target}" do
            expect(subject.last).to eq _target
          end
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
        elsif _target == :a
          it { is_expected.to eq 0 }
        else
          it { is_expected.to be > 0 }
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
