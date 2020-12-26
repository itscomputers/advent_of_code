require 'year2020/day14'

describe Year2020::Day14 do
  let(:day) { Year2020::Day14.new }

  describe 'part 1' do
    let(:raw_input) do
      <<~INPUT
        mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
        mem[8] = 11
        mem[7] = 101
        mem[8] = 0
      INPUT
    end

    before { allow(day).to receive(:raw_input).and_return raw_input }

    subject { day.solve part: 1 }
    it { is_expected.to eq 165 }
  end

  describe 'part 2' do
    let(:raw_input) do
      <<~INPUT
        mask = 000000000000000000000000000000X1001X
        mem[42] = 100
        mask = 00000000000000000000000000000000X0XX
        mem[26] = 1
      INPUT
    end

    before { allow(day).to receive(:raw_input).and_return raw_input }

    subject { day.solve part: 2 }
    it { is_expected.to eq 208 }
  end

  describe Year2020::Day14::Decoder do
    describe "#write_memory" do
      let(:decoder) { described_class.new [] }
      let(:mask) { "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X" }
      subject { decoder.memory[key] }

      before do
        decoder.write_mask(mask).write_memory(key, value)
        expect(decoder.mask).to eq({ 1 => 0, 6 => 1 })
      end

      context "example 1" do
        let(:key) { 8 }
        let(:value) { 11 }
        it { is_expected.to eq 73 }
      end

      context "example 2" do
        let(:key) { 7 }
        let(:value) { 101 }
        it { is_expected.to eq 101 }
      end

      context "example 3" do
        let(:key) { 8 }
        let(:value) { 0 }
        it { is_expected.to eq 64 }
      end
    end
  end

  describe Year2020::Day14::DecoderV2 do
    describe "#write_memory" do
      let(:decoder) { described_class.new [] }
      subject { decoder.memory }

      before do
        decoder.write_mask(mask).write_memory(key, value)
      end

      context "example 1" do
        let(:mask) { "000000000000000000000000000000X1001X" }
        let(:key) { 42 }
        let(:value) { 100 }
        it { is_expected.to eq [26, 27, 58, 59].map { |i| [i, 100] }.to_h }
      end
    end
  end
end

