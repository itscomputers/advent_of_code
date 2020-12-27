require 'year2019/day06'

describe Year2019::Day06 do
  let(:day) { Year2019::Day06.new }

  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    let(:raw_input) do
      <<~INPUT
        COM)B
        B)C
        C)D
        D)E
        E)F
        B)G
        G)H
        D)I
        E)J
        J)K
        K)L
      INPUT
    end
    subject { day.solve part: 1 }
    it { is_expected.to eq 42 }
  end

  describe 'part 2' do
    let(:raw_input) do
      <<~INPUT
        COM)B
        B)C
        C)D
        D)E
        E)F
        B)G
        G)H
        D)I
        E)J
        J)K
        K)L
        K)YOU
        I)SAN
      INPUT
    end
    subject { day.solve part: 2 }
    it { is_expected.to eq 4 }
  end
end

