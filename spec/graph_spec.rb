require "graph"

describe Graph do
  let(:graph) { builder.new(hash).build }

  describe "directed graph" do
    <<~GRAPH
      A  ----1--->  B  <---3--->  C
      |                          ^
      |------------2------------/
    GRAPH

    let(:builder) { Graph::DirectedGraphBuilder }
    let(:hash) { {
      "A" => {
        "B" => 1,
        "C" => 2,
      },
      "B" => {
        "C" => 3,
      },
      "C" => {
        "B" => 3,
      },
    } }

    describe "nodes" do
      subject { graph.nodes.map(&:value).sort }
      it { is_expected.to eq %w(A B C) }
    end

    describe "neighbors" do
      subject { graph.neighbors(node).map(&:value).sort }

      context "when node is A" do
        let(:node) { "A" }
        it { is_expected.to eq %w(B C) }
      end

      context "when node is B" do
        let(:node) { "B" }
        it { is_expected.to eq %w(C) }
      end

      context "when node is C" do
        let(:node) { "C" }
        it { is_expected.to eq %w(B) }
      end
    end

    describe "edges" do
      subject { node.edges }

      context "when node is A" do
        let(:node) { graph.node("A") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("A"), graph.node("B"), 1),
          "C" => Graph::Edge.new(graph.node("A"), graph.node("C"), 2),
        }) }
      end

      context "when node is B" do
        let(:node) { graph.node("B") }
        it { is_expected.to eq({
          "C" => Graph::Edge.new(graph.node("B"), graph.node("C"), 3),
        }) }
      end

      context "when node is C" do
        let(:node) { graph.node("C") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("C"), graph.node("B"), 3),
        }) }
      end
    end

    describe "distance" do
      subject { graph.distance(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 2 }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be_nil }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 3 }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be_nil }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 3 }
        end
      end
    end

    describe "adjacent" do
      subject { graph.adjacent?(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be false }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be false }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end
      end
    end
  end

  describe "undirected graph" do
    <<~GRAPH
      A  <---1--->  B  <---3--->  C
      ^                          ^
      |------------2------------/
    GRAPH

    let(:builder) { Graph::UndirectedGraphBuilder }
    let(:hash) { {
      "A" => {
        "B" => 1,
        "C" => 2,
      },
      "B" => {
        "C" => 3,
      },
      "C" => {
        "B" => 3,
      },
    } }

    describe "nodes" do
      subject { graph.nodes.map(&:value).sort }
      it { is_expected.to eq %w(A B C) }
    end

    describe "neighbors" do
      subject { graph.neighbors(node).map(&:value).sort }

      context "when node is A" do
        let(:node) { "A" }
        it { is_expected.to eq %w(B C) }
      end

      context "when node is B" do
        let(:node) { "B" }
        it { is_expected.to eq %w(A C) }
      end

      context "when node is C" do
        let(:node) { "C" }
        it { is_expected.to eq %w(A B) }
      end
    end

    describe "edges" do
      subject { node.edges }

      context "when node is A" do
        let(:node) { graph.node("A") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("A"), graph.node("B"), 1),
          "C" => Graph::Edge.new(graph.node("A"), graph.node("C"), 2),
        }) }
      end

      context "when node is B" do
        let(:node) { graph.node("B") }
        it { is_expected.to eq({
          "A" => Graph::Edge.new(graph.node("B"), graph.node("A"), 1),
          "C" => Graph::Edge.new(graph.node("B"), graph.node("C"), 3),
        }) }
      end

      context "when node is C" do
        let(:node) { graph.node("C") }
        it { is_expected.to eq({
          "A" => Graph::Edge.new(graph.node("C"), graph.node("A"), 2),
          "B" => Graph::Edge.new(graph.node("C"), graph.node("B"), 3),
        }) }
      end
    end

    describe "distance" do
      subject { graph.distance(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 2 }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 3 }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to eq 2 }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 3 }
        end
      end
    end

    describe "adjacent" do
      subject { graph.adjacent?(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be true }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end
      end
    end
  end

  describe "directed simple graph" do
    <<~GRAPH
      A  -------->  B  <------->  C
      |                          ^
      |-------------------------/
    GRAPH

    let(:builder) { Graph::SimpleDirectedGraphBuilder }
    let(:hash) { {
      "A" => %w(B C),
      "B" => %w(C),
      "C" => %w(B),
    } }

    describe "nodes" do
      subject { graph.nodes.map(&:value).sort }
      it { is_expected.to eq %w(A B C) }
    end

    describe "neighbors" do
      subject { graph.neighbors(node).map(&:value).sort }

      context "when node is A" do
        let(:node) { "A" }
        it { is_expected.to eq %w(B C) }
      end

      context "when node is B" do
        let(:node) { "B" }
        it { is_expected.to eq %w(C) }
      end

      context "when node is C" do
        let(:node) { "C" }
        it { is_expected.to eq %w(B) }
      end
    end

    describe "edges" do
      subject { node.edges }

      context "when node is A" do
        let(:node) { graph.node("A") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("A"), graph.node("B"), 1),
          "C" => Graph::Edge.new(graph.node("A"), graph.node("C"), 1),
        }) }
      end

      context "when node is B" do
        let(:node) { graph.node("B") }
        it { is_expected.to eq({
          "C" => Graph::Edge.new(graph.node("B"), graph.node("C"), 1),
        }) }
      end

      context "when node is C" do
        let(:node) { graph.node("C") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("C"), graph.node("B"), 1),
        }) }
      end
    end

    describe "distance" do
      subject { graph.distance(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 1 }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be_nil }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 1 }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be_nil }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end
      end
    end

    describe "adjacent" do
      subject { graph.adjacent?(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be false }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be false }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end
      end
    end
  end

  describe "simple undirected graph" do
    <<~GRAPH
      A  -------->  B  <------->  C
      |                          ^
      |-------------------------/
    GRAPH

    let(:builder) { Graph::SimpleUndirectedGraphBuilder }
    let(:hash) { {
      "A" => %w(B C),
      "B" => %w(C),
      "C" => %w(B),
    } }

    describe "nodes" do
      subject { graph.nodes.map(&:value).sort }
      it { is_expected.to eq %w(A B C) }
    end

    describe "neighbors" do
      subject { graph.neighbors(node).map(&:value).sort }

      context "when node is A" do
        let(:node) { "A" }
        it { is_expected.to eq %w(B C) }
      end

      context "when node is B" do
        let(:node) { "B" }
        it { is_expected.to eq %w(A C) }
      end

      context "when node is C" do
        let(:node) { "C" }
        it { is_expected.to eq %w(A B) }
      end
    end

    describe "edges" do
      subject { node.edges }

      context "when node is A" do
        let(:node) { graph.node("A") }
        it { is_expected.to eq({
          "B" => Graph::Edge.new(graph.node("A"), graph.node("B"), 1),
          "C" => Graph::Edge.new(graph.node("A"), graph.node("C"), 1),
        }) }
      end

      context "when node is B" do
        let(:node) { graph.node("B") }
        it { is_expected.to eq({
          "A" => Graph::Edge.new(graph.node("B"), graph.node("A"), 1),
          "C" => Graph::Edge.new(graph.node("B"), graph.node("C"), 1),
        }) }
      end

      context "when node is C" do
        let(:node) { graph.node("C") }
        it { is_expected.to eq({
          "A" => Graph::Edge.new(graph.node("C"), graph.node("A"), 1),
          "B" => Graph::Edge.new(graph.node("C"), graph.node("B"), 1),
        }) }
      end
    end

    describe "distance" do
      subject { graph.distance(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 1 }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to eq 1 }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to eq 1 }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to eq 1 }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to eq 1 }
        end
      end
    end

    describe "adjacent" do
      subject { graph.adjacent?(value, other) }

      context "from A" do
        let(:value) { "A" }

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from B" do
        let(:value) { "B" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be true }
        end

        context "to C" do
          let(:other) { "C" }
          it { is_expected.to be true }
        end
      end

      context "from C" do
        let(:value) { "C" }

        context "to A" do
          let(:other) { "A" }
          it { is_expected.to be true }
        end

        context "to B" do
          let(:other) { "B" }
          it { is_expected.to be true }
        end
      end
    end
  end
end
