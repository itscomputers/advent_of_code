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

    describe "example 2" do
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
  end

  describe "packets" do
    let(:packet) { Year2021::Day16::Packet.for_hex(hex) }

    describe "literal packet" do
      let(:hex) { "D2FE28" }

      it "is a literal packet" do
        expect(packet).to be_a Year2021::Day16::LiteralPacket
      end

      it "has binary 110100101111111000101000" do
        expect(packet.binary).to eq "110100101111111000101000"
      end

      it "has version 6" do
        expect(packet.version).to eq 6
      end

      it "has type_id 4" do
        expect(packet.type_id).to eq 4
      end

      it "has a value of 2021" do
        expect(packet.value).to eq 2021
      end

      it "has groups 10111 11110 00101" do
        expect(packet.groups).to eq %w(10111 11110 00101)
      end

      it "has leftover 000" do
        expect(packet.leftover).to eq "000"
      end
    end

    describe "operator packet with length type id 0" do
      let(:hex) { "38006F45291200" }

      it "is an operator packet" do
        expect(packet).to be_a Year2021::Day16::OperatorPacket
      end

      it "has binary 00111000000000000110111101000101001010010001001000000000" do
        expect(packet.binary).to eq "00111000000000000110111101000101001010010001001000000000"
      end

      it "has version 1" do
        expect(packet.version).to eq 1
      end

      it "has type_id 6" do
        expect(packet.type_id).to eq 6
      end
      it "has length type id 0" do
        expect(packet.length_type_id).to eq 0
      end

      it "has bit field length 15" do
        expect(packet.bit_field_length).to eq 15
      end

      it "has bit field 000000000011011" do
        expect(packet.bit_field).to eq "000000000011011"
      end

      it "has length 27" do
        expect(packet.length).to eq 27
      end

      it "has leftover 1101000101001010010001001000000000" do
        expect(packet.leftover).to eq "1101000101001010010001001000000000"
      end

      it "has a first subpacket with value 10 and leftover 01010010001001000000000" do
        packet.subpacket.tap do |subpacket|
          expect(subpacket.value).to eq 10
          expect(subpacket.leftover).to eq "01010010001001000000000"
        end
      end

      it "after processing first subpacket, it has a leftover of 01010010001001000000000" do
        packet.process_subpacket
        expect(packet.leftover).to eq "01010010001001000000000"
      end

      it "has a second subpacket with value 20 and leftover 0000000" do
        packet.process_subpacket.subpacket.tap do |subpacket|
          expect(subpacket.value).to eq 20
          expect(subpacket.leftover).to eq "0000000"
        end
      end

      it "has a total of two subpackets with values of 10 and 20" do
        expect(packet.process_subpackets.subpackets.map(&:value)).to eq [10, 20]
      end
    end

    describe "operator packet with length type id 0" do
      let(:hex) { "EE00D40C823060" }

      it "is an operator packet" do
        expect(packet).to be_a Year2021::Day16::OperatorPacket
      end

      it "has 3 subpackets with values 1, 2, 3" do
        expect(packet.process_subpackets.subpackets.map(&:value)).to eq [1, 2, 3]
      end
    end
  end
end
