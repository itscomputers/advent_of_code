require "year2022/day16"

describe Year2022::Day16 do
  let(:day) { Year2022::Day16.new }
  before do
    allow(day).to receive(:raw_input).and_return <<~RAW_INPUT
      Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
      Valve BB has flow rate=13; tunnels lead to valves CC, AA
      Valve CC has flow rate=2; tunnels lead to valves DD, BB
      Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
      Valve EE has flow rate=3; tunnels lead to valves FF, DD
      Valve FF has flow rate=0; tunnels lead to valves EE, GG
      Valve GG has flow rate=0; tunnels lead to valves FF, HH
      Valve HH has flow rate=22; tunnel leads to valve GG
      Valve II has flow rate=0; tunnels lead to valves AA, JJ
      Valve JJ has flow rate=21; tunnel leads to valve II
    RAW_INPUT
  end

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 1651 }
  end

  describe "flow rates" do
    subject { day.initial_graph.instance_variable_get(:@flow_rate_lookup) }
    let(:expected_flow_rates) { {
      "AA"=> 0,
      "BB"=> 13,
      "CC"=> 2,
      "DD"=> 20,
      "EE"=> 3,
      "FF"=> 0,
      "GG"=> 0,
      "HH"=> 22,
      "II"=> 0,
      "JJ"=> 21,
    } }
    it { is_expected.to eq expected_flow_rates }
  end

  describe "initial graph neighbors" do
    subject { day.initial_graph.instance_variable_get(:@neighbor_lookup) }
    let(:expected_neighbors) { {
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
    it { is_expected.to eq expected_neighbors }
  end

  describe "pruned graph neighbors" do
    subject { day.pruned_graph.instance_variable_get(:@neighbor_lookup) }
    let(:expected_neighbors) { {
      "AA" => {"BB" => 1, "CC" => 2, "DD" => 1, "EE" => 2, "HH" => 5, "JJ" => 2},
      "BB" => {           "CC" => 1, "DD" => 2, "EE" => 3, "HH" => 6, "JJ" => 3},
      "CC" => {"BB" => 1,            "DD" => 1, "EE" => 2, "HH" => 5, "JJ" => 4},
      "DD" => {"BB" => 2, "CC" => 1,            "EE" => 1, "HH" => 4, "JJ" => 3},
      "EE" => {"BB" => 3, "CC" => 2, "DD" => 1,            "HH" => 3, "JJ" => 4},
      "HH" => {"BB" => 6, "CC" => 5, "DD" => 4, "EE" => 3,            "JJ" => 7},
      "JJ" => {"BB" => 3, "CC" => 4, "DD" => 3, "EE" => 4, "HH" => 7           },
    } }
    it { is_expected.to eq expected_neighbors }
  end

  describe "valve_graph" do
    let(:valve_graph) { day.valve_graph }

    describe "root" do
      let(:root) { valve_graph.root }

      it { expect(root.value).to eq "AA" }
      it { expect(root.on?).to be true }

      describe "neighbors" do
        let(:neighbors) { valve_graph.neighbors(root) }
        it { expect(neighbors.map(&:value)).to match_array %w(BB CC DD EE HH JJ) }
        it do
          neighbors.map(&:bitmask).each do |bitmask|
            expect(bitmask).to eq root.bitmask
          end
        end

        %w(BB CC DD EE HH JJ).each do |value|
          describe "when #{value} is on" do
            before { root.bitmask = root.bitmask.copy_with(value) }
            it { expect(neighbors.map(&:value)).to_not include value }
          end
        end
      end
    end
  end
end
