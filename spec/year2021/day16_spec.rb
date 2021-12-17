require "year2021/day16"

describe Year2021::Day16 do
  let(:day) { Year2021::Day16.new(raw_input) }

  describe "part 1" do
    subject { day.solve(part: 1) }

    describe "example 1" do
      let(:raw_input) { "8A004A801A8002F478" }
      it { is_expected.to eq 16 }
    end

    describe "example 2" do
      let(:raw_input) { "620080001611562C8802118E34" }
      it { is_expected.to eq 12 }
    end

    describe "example 3" do
      let(:raw_input) { "C0015000016115A2E0802F182340" }
      it { is_expected.to eq 23 }
    end

    describe "example 4" do
      let(:raw_input) { "A0016C880162017C3686B18A3D4780" }
      it { is_expected.to eq 31 }
    end
  end

  describe "part 2" do
    subject { day.solve(part: 2) }

    describe "example 1" do
      let(:raw_input) { "C200B40A82" }
      it { is_expected.to eq 3 }
    end

    describe "example 2" do
      let(:raw_input) { "04005AC33890" }
      it { is_expected.to eq 54 }
    end

    describe "example 3" do
      let(:raw_input) { "880086C3E88112" }
      it { is_expected.to eq 7 }
    end

    describe "example 4" do
      let(:raw_input) { "CE00C43D881120" }
      it { is_expected.to eq 9 }
    end

    describe "example 5" do
      let(:raw_input) { "D8005AC2A8F0" }
      it { is_expected.to eq 1 }
    end

    describe "example 6" do
      let(:raw_input) { "F600BC2D8F" }
      it { is_expected.to eq 0 }
    end

    describe "example 7" do
      let(:raw_input) { "9C005AC2F8F0" }
      it { is_expected.to eq 0 }
    end

    describe "example 8" do
      let(:raw_input) { "9C0141080250320F1802104A08" }
      it { is_expected.to eq 1 }
    end

    describe "complex example 1" do
      <<~PACKET
        <OperatorPacket 2 (
          <OperatorPacket 2 (
            <OperatorPacket 2 (
              <LiteralPacket 4>
            )>
          )>
        )>
        min of (
          min of (
            min of (
              15
            )
          )
        )
      PACKET
      let(:raw_input) { "8A004A801A8002F478" }
      it { is_expected.to eq 15 }
    end

    describe "complex example 2" do
      <<~PACKET
        <OperatorPacket 0 (
          <OperatorPacket 0 (
            <LiteralPacket 4>
            <LiteralPacket 4>
            <OperatorPacket 0 (
              <LiteralPacket 4>
              <LiteralPacket 4>
            )>
          )>
          <EmptyPacket>
        )>
        sum of (
          sum of (
            10
            11
            sum of (
              12
              13
            )
          )
          0
        )
      PACKET
      let(:raw_input) { "620080001611562C8802118E34" }
      it { is_expected.to eq 46 }
    end

    describe "complex example 3" do
      <<~PACKET
        <OperatorPacket 0 (
          <OperatorPacket 0 (
            <LiteralPacket 4>,
            <LiteralPacket 4>,
            <OperatorPacket 0 (
              <LiteralPacket 4>,
              <LiteralPacket 4>
            )>
          )>
        )>
        sum of (
          sum of (
            10
            11
            sum of (
              12
              13
            )
          )
        )
      PACKET
      let(:raw_input) { "C0015000016115A2E0802F182340" }
      it { is_expected.to eq 46 }
    end

    describe "complex example 4" do
      <<~PACKET
        <OperatorPacket 0 (
          <OperatorPacket 0 (
            <OperatorPacket 0 (
              <LiteralPacket 4>,
              <LiteralPacket 4>,
              <LiteralPacket 4>,
              <LiteralPacket 4>,
              <LiteralPacket 4>
            )>
          )>
        )>
        sum of (
          sum of (
            sum of (
              6
              6
              12
              15
              15
            )
          )
        )
      PACKET
      let(:raw_input) { "A0016C880162017C3686B18A3D4780" }
      it { is_expected.to eq 54 }
    end
  end

  describe "packets" do
    let(:packet) { Year2021::Day16::Packet.new(Year2021::Day16::BitStream.new(hex, type: :hex)) }

    describe "literal packet" do
      let(:hex) { "D2FE28" }

      it "has version 6" do
        expect(packet.version).to eq 6
      end

      it "has type_id 4" do
        expect(packet.type_id).to eq 4
      end

      it "has a value of 2021" do
        expect(packet.value).to eq 2021
      end

      it "has leftover 000" do
        expect(packet.bit_stream.take(3)).to eq "000"
        expect { packet.bit_stream.take }.to raise_exception StopIteration
      end
    end

    describe "operator packet with length type id 0" do
      let(:hex) { "38006F45291200" }

      it "has version 1" do
        expect(packet.version).to eq 1
      end

      it "has type_id 6" do
        expect(packet.type_id).to eq 6
      end

      it "has a total of two subpackets with values of 10 and 20" do
        expect(packet.subpackets.map(&:value)).to eq [10, 20]
      end
    end

    describe "operator packet with length type id 1" do
      let(:hex) { "EE00D40C823060" }

      it "has version 7" do
        expect(packet.version).to eq 7
      end

      it "has type_id 3" do
        expect(packet.type_id).to eq 3
      end

      it "has 3 subpackets with values 1, 2, 3" do
        expect(packet.subpackets.map(&:value)).to eq [1, 2, 3]
      end
    end
  end
end
