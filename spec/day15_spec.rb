require 'advent/day15'

describe Advent::Day15 do
  describe "part 1" do
    before { allow(described_class).to receive(:raw_input).and_return raw_input }

    subject { described_class.build.solve part: 1 }

    {
      "0,3,6" => 436,
      "1,3,2" => 1,
      "2,1,3" => 10,
      "1,2,3" => 27,
      "2,3,1" => 78,
      "3,2,1" => 438,
      "3,1,2" => 1836,
    }.each do |raw_input, expected_result|
      describe "when raw_input is #{raw_input}" do
        let(:raw_input) { raw_input }
        it { is_expected.to eq expected_result }
      end
    end
  end
end

