require 'year2019/day18'
require "graph"

describe Year2019::Day18 do
  let(:day) { Year2019::Day18.new }
  let(:input_1) do
    <<~INPUT
      ########################
      #f.D.E.e.C.b.A.@.a.B.c.#
      ######################.#
      #d.....................#
      ########################
    INPUT
  end
  let(:input_2) do
    <<~INPUT
      ########################
      #...............b.C.D.f#
      #.######################
      #.....@.a.B.c.d.A.e.F.g#
      ########################
    INPUT
  end
  let(:input_3) do
    <<~INPUT
      #################
      #i.G..c...e..H.p#
      ########.########
      #j.A..b...f..D.o#
      ########@########
      #k.E..a...g..B.n#
      ########.########
      #l.F..d...h..C.m#
      #################
    INPUT
  end
  let(:input_4) do
    <<~INPUT
      ########################
      #@..............ac.GI.b#
      ###d#e#f################
      ###A#B#C################
      ###g#h#i################
      ########################
    INPUT
  end

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe "unreduced graph" do
    let(:raw_input) { input_1 }
    let(:graph) { Year2019::Day18::GraphBuilder.new(day.symbol_lookup).graph }
    it do
      expect(graph.nodes.map(&:value)).to match_array [
        *%w(A B C D E a b c d e f @),
        *(2..22).step(2).to_a.map { |x| "#{x},1" },
        *(2..22).map { |x| "#{x},3" },
        "22,2",
      ]
    end
  end

  describe Year2019::Day18::EdgeReducer do
    let(:raw_input) { input_1 }
    let(:graph) { Year2019::Day18::GraphBuilder.new(day.symbol_lookup).graph }
    subject { described_class.new(node).reduce.edges }

    context "when node is d" do
      let(:node) { graph.node("d") }
      it do
        is_expected.to eq({
          "c" => Graph::Edge.new(graph.node("d"), graph.node("c"), 24),
        })
      end
    end

    context "when node is @" do
      let(:node) { graph.node("@") }
      it do
        is_expected.to eq({
          "a" => Graph::Edge.new(graph.node("@"), graph.node("a"), 2),
          "A" => Graph::Edge.new(graph.node("@"), graph.node("A"), 2),
        })
      end
    end
  end

  describe "graph" do
    let(:graph) { day.graph }
    subject { graph.to_h }

    context 'example 1' do
      let(:raw_input) { input_1 }
      it { is_expected.to eq({
        "@" => { "a" => 2, "A" => 2 },
        "a" => { "@" => 2, "B" => 2 },
        "b" => { "A" => 2, "C" => 2 },
        "c" => { "B" => 2, "d" => 24 },
        "d" => { "c" => 24 },
        "e" => { "C" => 2, "E" => 2 },
        "f" => { "D" => 2 },
        "A" => { "@" => 2, "b" => 2 },
        "B" => { "a" => 2, "c" => 2 },
        "C" => { "b" => 2, "e" => 2 },
        "D" => { "E" => 2, "f" => 2 },
        "E" => { "D" => 2, "e" => 2 },
      }) }
    end

    context 'example 2' do
      let(:raw_input) { input_2 }
      it { is_expected.to eq({
        "@" => { "a" => 2, "b" => 22 },
        "a" => { "@" => 2, "B" => 2 },
        "b" => { "@" => 22, "C" => 2 },
        "c" => { "B" => 2, "d" => 2 },
        "d" => { "A" => 2, "c" => 2 },
        "e" => { "A" => 2, "F" => 2 },
        "f" => { "D" => 2 },
        "g" => { "F" => 2 },
        "A" => { "d" => 2, "e" => 2 },
        "B" => { "a" => 2, "c" => 2 },
        "C" => { "b" => 2, "D" => 2 },
        "D" => { "C" => 2, "f" => 2 },
        "F" => { "e" => 2, "g" => 2 },
      }) }
    end

    context 'example 3' do
      let(:raw_input) { input_3 }
      it { is_expected.to eq({
        "@" => { "a" => 3, "b" => 3, "c" => 5, "d" => 5, "e" => 5, "f" => 3, "g" => 3, "h" => 5 },
        "a" => { "E" => 3, "@" => 3, "d" => 6, "g" => 4, "h" => 6 },
        "b" => { "A" => 3, "@" => 3, "c" => 6, "e" => 6, "f" => 4 },
        "c" => { "G" => 3, "@" => 5, "b" => 6, "e" => 4, "f" => 6 },
        "d" => { "F" => 3, "@" => 5, "a" => 6, "g" => 6, "h" => 4 },
        "e" => { "H" => 3, "@" => 5, "b" => 6, "c" => 4, "f" => 6 },
        "f" => { "D" => 3, "@" => 3, "b" => 4, "c" => 6, "e" => 6 },
        "g" => { "B" => 3, "@" => 3, "a" => 4, "d" => 6, "h" => 6 },
        "h" => { "C" => 3, "@" => 5, "a" => 6, "d" => 4, "g" => 6 },
        "i" => { "G" => 2 },
        "j" => { "A" => 2 },
        "k" => { "E" => 2 },
        "l" => { "F" => 2 },
        "m" => { "C" => 2 },
        "n" => { "B" => 2 },
        "o" => { "D" => 2 },
        "p" => { "H" => 2 },
        "A" => { "b" => 3, "j" => 2 },
        "B" => { "g" => 3, "n" => 2 },
        "C" => { "h" => 3, "m" => 2 },
        "D" => { "f" => 3, "o" => 2 },
        "E" => { "a" => 3, "k" => 2 },
        "F" => { "d" => 3, "l" => 2 },
        "G" => { "c" => 3, "i" => 2 },
        "H" => { "e" => 3, "p" => 2 },
      }) }
    end

    context 'example 4' do
      let(:raw_input) { input_4 }
      it { is_expected.to eq({
        "@" => { "a" => 15, "d" => 3, "e" => 5, "f" => 7 },
        "a" => { "@" => 15, "c" => 1, "d" => 14, "e" => 12, "f" => 10 },
        "b" => { "I" => 2 },
        "c" => { "a" => 1, "G" => 2 },
        "d" => { "@" => 3, "a" => 14, "e" => 4, "f" => 6, "A" => 1 },
        "e" => { "@" => 5, "a" => 12, "d" => 4, "f" => 4, "B" => 1 },
        "f" => { "@" => 7, "a" => 10, "d" => 6, "e" => 4, "C" => 1 },
        "g" => { "A" => 1 },
        "h" => { "B" => 1 },
        "i" => { "C" => 1 },
        "A" => { "d" => 1, "g" => 1 },
        "B" => { "e" => 1, "h" => 1 },
        "C" => { "f" => 1, "i" => 1 },
        "G" => { "c" => 2, "I" => 1 },
        "I" => { "b" => 2, "G" => 1 },
      }) }
    end
  end

# xdescribe 'Graph#neighbors_of' do
#   let(:graph) { day.key_graph }
#   subject { graph.neighbors_of(graph.node_for [char, keys]) }

#   def has_nodes(*node_values)
#     expect(subject.map(&:value)).to match_array node_values
#   end

#   context "example 1" do
#     let(:raw_input) { input_1 }

#     context "when char is @ and keys is 0" do
#       let(:char) { "@" }
#       let(:keys) { 0 }
#       it { has_nodes ["a", 0] }
#     end

#     context "when char is a and keys is 0" do
#       let(:char) { "a" }
#       let(:keys) { 0 }
#       it { has_nodes ["a", 1] }
#     end

#     context "when char is A and keys is 1" do
#       let(:char) { "A" }
#       let(:keys) { 1 }
#       it { has_nodes ["a", 1], ["b", 1] }
#     end
#   end

#   context "example 3" do
#     let(:raw_input) { input_3 }

#     context "when char is @ and keys is 0" do
#       let(:char) { "@" }
#       let(:keys) { 0 }
#       it { has_nodes *('a'..'h').map { |c| [c, 0] } }
#     end

#     context "when char is a and keys is 0" do
#       let(:char) { "a" }
#       let(:keys) { 0 }
#       it { has_nodes ["a", 1] }
#     end

#     context "when char is a and keys is 16" do
#       let(:char) { "a" }
#       let(:keys) { 16 }
#       it { has_nodes ["a", 17] }
#     end

#     context "when char is a and keys is 17" do
#       let(:char) { "a" }
#       let(:keys) { 17 }
#       it { has_nodes ["E", 17], *('b'..'h').map { |c| [c, 17] } }
#     end
#   end
# end

  describe 'part 1' do
    subject { day.solve part: 1 }

    context 'example 1' do
      let(:raw_input) { input_1 }
      it { is_expected.to eq 86 }
    end

    context 'example 2' do
      let(:raw_input) { input_2 }
      it { is_expected.to eq 132 }
    end

    context 'example 3' do
      let(:raw_input) { input_3 }
      it { is_expected.to eq 136 }
    end

    context 'example 4' do
      let(:raw_input) { input_4 }
      it { is_expected.to eq 81 }
    end
  end

  describe 'part 2' do
    subject { day.solve part: 2 }

    context 'example 1' do
      let(:raw_input) do
        <<~INPUT
          #######
          #a.#Cd#
          ##...##
          ##.@.##
          ##...##
          #cB#Ab#
          #######
        INPUT
      end
      it { is_expected.to eq 8 }
    end

    context 'example 2' do
      let(:raw_input) do
        <<~INPUT
          ###############
          #d.ABC.#.....a#
          ######...######
          ######.@.######
          ######...######
          #b.....#.....c#
          ###############
        INPUT
      end
      it { is_expected.to eq 24 }
    end

    context 'example 3' do
      let(:raw_input) do
        <<~INPUT
          #############
          #g#f.D#..h#l#
          #F###e#E###.#
          #dCba...BcIJ#
          #####.@.#####
          #nK.L...G...#
          #M###N#H###.#
          #o#m..#i#jk.#
          #############
        INPUT
      end
      it { is_expected.to eq 72 }
    end
  end
end

