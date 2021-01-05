require 'year2019/day18'

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

#   slow spec
    context 'example 3' do
      let(:raw_input) { input_3 }
      it { is_expected.to eq 136 }
    end

    context 'example 4' do
      let(:raw_input) { input_4 }
      it { is_expected.to eq 81 }
    end
  end
end

