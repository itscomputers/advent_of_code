require 'year2019/day01'

describe Year2019::Day01 do
  let(:day) { Year2019::Day01.new }

  describe '#fuel' do
    subject { day.fuel mass }

    {
      12 => 2,
      14 => 2,
      1969 => 654,
      100756 => 33583,
    }.each do |mass, result|
      context "when mass is #{mass}" do
        let(:mass) { mass }
        it { is_expected.to eq result }
      end
    end
  end

  describe '#fuel_for_fuel' do
    subject { day.fuel_for_fuel mass }

    {
      14 => 2,
      1969 => 966,
      100756 => 50346,
    }.each do |mass, result|
      context "when mass is #{mass}" do
        let(:mass) { mass }
        it { is_expected.to eq result }
      end
    end
  end
end

