require 'year2019/day12'

describe Year2019::Day12 do
  let(:day) { Year2019::Day12.new }
  let(:input_1) do
    <<~INPUT
      <x=-1, y=0, z=2>
      <x=2, y=-10, z=-7>
      <x=4, y=-8, z=8>
      <x=3, y=5, z=-1>
    INPUT
  end
  let(:input_2) do
    <<~INPUT
      <x=-8, y=-10, z=0>
      <x=5, y=5, z=10>
      <x=2, y=-7, z=3>
      <x=9, y=-8, z=-3>
    INPUT
  end

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }

    before { allow(day).to receive(:generations).and_return generations }

    context 'example 1' do
      let(:raw_input) { input_1 }
      let(:generations) { 10 }
      it { is_expected.to eq 179 }
    end

    context 'example 2' do
      let(:raw_input) { input_2 }
      let(:generations) { 100 }
      it { is_expected.to eq 1940 }
    end
  end

  describe 'part 2' do
    subject { day.solve part: 2 }

    context 'example 1' do
      let(:raw_input) { input_1 }
      it { is_expected.to eq 2772 }
    end

    context 'example 2' do
      let(:raw_input) { input_2 }
      it { is_expected.to eq 4686774924 }
    end
  end
end

