require "a_star"
require "graph"

describe AStarSimple do
  let(:graph) do
    Graph::DirectedGraphBuilder.new({
      "A" => {
        "B" => 1,
        "C" => 3,
        "D" => 6,
      },
      "B" => {
        "C" => 1,
        "D" => 5,
        "E" => 3,
      },
      "C" => {
        "D" => 2,
      },
      "D" => {
        "E" => 1,
        "F" => 4,
        "G" => 1,
      },
      "E" => {
        "F" => 5,
        "G" => 5,
      },
    }).build
  end
  let(:start) { graph.node("A") }
  let(:a_star) { AStarSimple.new(start, goal).execute }

  context "when goal is C" do
    let(:goal) { graph.node("C") }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 2 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B C) }
    end
  end

  context "when goal is D" do
    let(:goal) { graph.node("D") }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 4 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B C D) }
    end
  end

  context "when goal is E" do
    let(:goal) { graph.node("E") }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 4 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B E) }
    end
  end

  context "when goal is F" do
    let(:goal) { graph.node("F") }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 8 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B C D F) }
    end
  end

  context "when goal is G" do
    let(:goal) { graph.node("G") }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 5 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B C D G) }
    end
  end

  describe AStarDynamic do
    let(:goal) { lambda { |node| %w(F G).include?(node.value) } }
    let(:a_star) { AStarDynamic.new(start, goal).execute }

    describe "min_path_cost" do
      it { expect(a_star.min_path_cost).to eq 5 }
    end

    describe "min_path" do
      it { expect(a_star.min_path.map(&:node).map(&:value)).to eq %w(A B C D G) }
    end
  end

  describe AStarGraph do
    let(:start) { "A" }
    let(:a_star) { AStarGraph.new(start, goal, graph: graph).execute }

    context "when goal is C" do
      let(:goal) { "C" }

      describe "min_path_cost" do
        it { expect(a_star.min_path_cost).to eq 2 }
      end

      describe "min_path" do
        it { expect(a_star.min_path.map(&:node)).to eq %w(A B C) }
      end
    end

    context "when goal is D" do
      let(:goal) { "D" }

      describe "min_path_cost" do
        it { expect(a_star.min_path_cost).to eq 4 }
      end

      describe "min_path" do
        it { expect(a_star.min_path.map(&:node)).to eq %w(A B C D) }
      end
    end

    context "when goal is E" do
      let(:goal) { "E" }

      describe "min_path_cost" do
        it { expect(a_star.min_path_cost).to eq 4 }
      end

      describe "min_path" do
        it { expect(a_star.min_path.map(&:node)).to eq %w(A B E) }
      end
    end

    context "when goal is F" do
      let(:goal) { "F" }

      describe "min_path_cost" do
        it { expect(a_star.min_path_cost).to eq 8 }
      end

      describe "min_path" do
        it { expect(a_star.min_path.map(&:node)).to eq %w(A B C D F) }
      end
    end

    context "when goal is G" do
      let(:goal) { "G" }

      describe "min_path_cost" do
        it { expect(a_star.min_path_cost).to eq 5 }
      end

      describe "min_path" do
        it { expect(a_star.min_path.map(&:node)).to eq %w(A B C D G) }
      end
    end
  end
end

