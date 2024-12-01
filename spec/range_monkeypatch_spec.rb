require "range_monkeypatch"

describe "overlap?" do
  subject { (5..15).overlap?(other) }

  [
    {other: (0..3), expected: false},
    {other: (0..4), expected: true},
    {other: (0..5), expected: true},
    {other: (0..9), expected: true},
    {other: (0..15), expected: true},
    {other: (0..16), expected: true},
    {other: (0..20), expected: true},
    {other: (4..20), expected: true},
    {other: (5..20), expected: true},
    {other: (9..20), expected: true},
    {other: (15..20), expected: true},
    {other: (16..20), expected: true},
    {other: (17..20), expected: false},
    {other: (5..15), expected: true},
    {other: (9..15), expected: true},
    {other: (11..15), expected: true},
  ].each do |data|
    context "when other is #{data[:other]}" do
      let(:other) { data[:other] }
      it { is_expected.to be data[:expected] }
    end
  end
end

describe "union" do
  subject { (5..15).restricted_union(other) }

  [
    {other: (0..3), expected: nil},
    {other: (0..4), expected: (0..15)},
    {other: (0..5), expected: (0..15)},
    {other: (0..9), expected: (0..15)},
    {other: (0..15), expected: (0..15)},
    {other: (0..16), expected: (0..16)},
    {other: (0..20), expected: (0..20)},
    {other: (4..20), expected: (4..20)},
    {other: (5..20), expected: (5..20)},
    {other: (9..20), expected: (5..20)},
    {other: (15..20), expected: (5..20)},
    {other: (16..20), expected: (5..20)},
    {other: (17..20), expected: nil},
    {other: (5..15), expected: (5..15)},
    {other: (9..15), expected: (5..15)},
    {other: (11..15), expected: (5..15)},
    {other: (9..11), expected: (5..15)},
  ].each do |data|
    context "when other is #{data[:other]}" do
      let(:other) { data[:other] }
      it { is_expected.to eq data[:expected] }
    end
  end
end

describe "intersection" do
  subject { (5..15).intersection(other) }

  [
    {other: (0..3), expected: nil},
    {other: (0..4), expected: nil},
    {other: (0..5), expected: (5..5)},
    {other: (0..9), expected: (5..9)},
    {other: (0..15), expected: (5..15)},
    {other: (0..16), expected: (5..15)},
    {other: (0..20), expected: (5..15)},
    {other: (4..20), expected: (5..15)},
    {other: (5..20), expected: (5..15)},
    {other: (9..20), expected: (9..15)},
    {other: (15..20), expected: (15..15)},
    {other: (16..20), expected: nil},
    {other: (17..20), expected: nil},
    {other: (5..15), expected: (5..15)},
    {other: (9..15), expected: (9..15)},
    {other: (11..15), expected: (11..15)},
    {other: (9..11), expected: (9..11)},
  ].each do |data|
    context "when other is #{data[:other]}" do
      let(:other) { data[:other] }
      it { is_expected.to eq data[:expected] }
    end
  end
end

describe "unions" do
  subject { (5..10).union(others) }

  [
    {others: [(1..3)], expected: [(1..3), (5..10)]},
    {others: [(1..4)], expected: [(1..10)]},
    {others: [(1..5)], expected: [(1..10)]},
    {others: [(1..8)], expected: [(1..10)]},
    {others: [(1..10)], expected: [(1..10)]},
    {others: [(1..14)], expected: [(1..14)]},
    {others: [(5..14)], expected: [(5..14)]},
    {others: [(7..14)], expected: [(5..14)]},
    {others: [(10..14)], expected: [(5..14)]},
    {others: [(11..14)], expected: [(5..14)]},
    {others: [(12..14)], expected: [(5..10), (12..14)]},
    {others: [(1..3), (12..14)], expected: [(1..3), (5..10), (12..14)]},
    {others: [(1..4), (12..14)], expected: [(1..10), (12..14)]},
    {others: [(1..3), (11..14)], expected: [(1..3), (5..14)]},
    {others: [(1..4), (10..14)], expected: [(1..14)]},
    {others: [(1..6), (10..14), (12..20), (15..30)], expected: [(1..30)]},
  ].each do |data|
    context "when others are #{data[:others]}" do
      let(:others) { data[:others] }
      it { is_expected.to match_array data[:expected] }
    end
  end

  describe "subtract" do
    subject { (5..10).subtract(other) }

    [
      {other: (1..3), expected: [(5..10)]},
      {other: (1..4), expected: [(5..10)]},
      {other: (1..5), expected: [6..10]},
      {other: (1..8), expected: [9..10]},
      {other: (1..10), expected: []},
      {other: (1..14), expected: []},
      {other: (5..14), expected: []},
      {other: (7..14), expected: [(5..6)]},
      {other: (10..14), expected: [(5..9)]},
      {other: (11..14), expected: [(5..10)]},
      {other: (12..14), expected: [(5..10)]},
      {other: (5..10), expected: []},
      {other: (7..10), expected: [(5..6)]},
      {other: (7..8), expected: [(5..6), (9..10)]},
      {other: (5..8), expected: [(9..10)]},
    ].each do |data|
      context "when other is #{data[:other]}" do
        let(:other) { data[:other] }
        it { is_expected.to match_array data[:expected] }
      end
    end
  end
end
