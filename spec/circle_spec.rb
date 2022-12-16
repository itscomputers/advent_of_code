require "circle"

describe Circle do
  let(:center) { [3, -1] }
  let(:circle) { described_class.new(center, radius) }

  def expected_border(center, radius)
    (-10..15)
      .flat_map { |x| (-12..10).map { |y| [x, y] } }
      .select { |point| Point.distance(point, center) == radius }
  end

  (0..5).each do |idx|
    context "when radius is #{idx}" do
      let(:radius) { idx }

      describe "border_points" do
        subject { circle.border_points }
        it { is_expected.to match_array expected_border(center, radius) }
      end

      describe "horizon_points" do
        subject { circle.horizon_points }
        it { is_expected.to match_array expected_border(center, radius + 1) }
      end
    end
  end

  describe "x_range" do
    let(:radius) { 5 }
    it { expect(circle.x_range).to eq (-2..8) }

    [
      {y_value: -7, expected: nil},
      {y_value: -6, expected: (3..3)},
      {y_value: -5, expected: (2..4)},
      {y_value: -4, expected: (1..5)},
      {y_value: -3, expected: (0..6)},
      {y_value: -2, expected: (-1..7)},
      {y_value: -1, expected: (-2..8)},
      {y_value: 0, expected: (-1..7)},
      {y_value: 1, expected: (0..6)},
      {y_value: 2, expected: (1..5)},
      {y_value: 3, expected: (2..4)},
      {y_value: 4, expected: (3..3)},
      {y_value: 5, expected: nil},
    ].each do |data|
      context "when y_value is #{data[:y_value]}" do
        subject { circle.x_range(y_value: data[:y_value]) }
        it { is_expected.to eq data[:expected] }
      end
    end
  end

  describe "y_range" do
    let(:radius) { 5 }
    it { expect(circle.y_range).to eq (-6..4) }

    [
      {x_value: -3, expected: nil},
      {x_value: -2, expected: (-1..-1)},
      {x_value: -1, expected: (-2..0)},
      {x_value: 0, expected: (-3..1)},
      {x_value: 1, expected: (-4..2)},
      {x_value: 2, expected: (-5..3)},
      {x_value: 3, expected: (-6..4)},
      {x_value: 4, expected: (-5..3)},
      {x_value: 5, expected: (-4..2)},
      {x_value: 6, expected: (-3..1)},
      {x_value: 7, expected: (-2..0)},
      {x_value: 8, expected: (-1..-1)},
      {x_value: 9, expected: nil},
    ].each do |data|
      context "when x_value is #{data[:x_value]}" do
        subject { circle.y_range(x_value: data[:x_value]) }
        it { is_expected.to eq data[:expected] }
      end
    end
  end
end

