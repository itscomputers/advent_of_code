require 'year2020/day15'

describe Year2020::Day15 do
  let(:day) { Year2020::Day15.new }
  before { allow(day).to receive(:raw_input).and_return raw_input }

  describe "part 1" do
    subject { day.solve part: 1 }

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

  describe "part 2" do
    subject { day.solve part: 2 }

    {
# slow specs
#     "0,3,6" => 175594,
#     "1,3,2" => 2578,
#     "2,1,3" => 3544142,
#     "1,2,3" => 261214,
#     "2,3,1" => 6895259,
#     "3,2,1" => 18,
#     "3,1,2" => 362,
    }.each do |raw_input, expected_result|
      describe "when raw_input is #{raw_input}" do
        let(:raw_input) { raw_input }
        it { is_expected.to eq expected_result }
      end
    end
  end
end

