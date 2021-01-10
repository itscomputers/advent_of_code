require 'year2019/day18'

describe Year2019::Day18 do
  let(:day) { Year2019::Day18.new }

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }

    context 'example 1' do
      let(:raw_input) do
        <<~INPUT
          ########################
          #f.D.E.e.C.b.A.@.a.B.c.#
          ######################.#
          #d.....................#
          ########################
        INPUT
      end
      it { is_expected.to eq 86 }
    end

    context 'example 2' do
      let(:raw_input) do
        <<~INPUT
          ########################
          #...............b.C.D.f#
          #.######################
          #.....@.a.B.c.d.A.e.F.g#
          ########################
        INPUT
      end
      it { is_expected.to eq 132 }
    end

#   slow spec
#   context 'example 3' do
#     let(:raw_input) do
#       <<~INPUT
#         #################
#         #i.G..c...e..H.p#
#         ########.########
#         #j.A..b...f..D.o#
#         ########@########
#         #k.E..a...g..B.n#
#         ########.########
#         #l.F..d...h..C.m#
#         #################
#       INPUT
#     end
#     it { is_expected.to eq 136 }
#   end

    context 'example 4' do
      let(:raw_input) do
        <<~INPUT
          ########################
          #@..............ac.GI.b#
          ###d#e#f################
          ###A#B#C################
          ###g#h#i################
          ########################
        INPUT
      end
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

#   slow spec
#   context 'example 2' do
#     let(:raw_input) do
#       <<~INPUT
#         ###############
#         #d.ABC.#.....a#
#         ######...######
#         ######.@.######
#         ######...######
#         #b.....#.....c#
#         ###############
#       INPUT
#     end
#     it { is_expected.to eq 24 }
#   end

#   slow spec
#   context 'example 3' do
#     let(:raw_input) do
#       <<~INPUT
#         #############
#         ##g#f.D#..h#l
#         #F###e#E###.#
#         #dCba...BcIJ#
#         #####.@.#####
#         #nK.L...G...#
#         #M###N#H###.#
#         #o#m..#i#jk.#
#         #############
#       INPUT
#     end
#     it { is_expected.to eq 72 }
#   end
  end
end

