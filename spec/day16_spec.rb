require 'advent/day16'

describe Advent::Day16 do
  let(:day) { Advent::Day16.build }
  let(:raw_input) do
    <<~INPUT
      class: 1-3 or 5-7
      row: 6-11 or 33-44
      seat: 13-40 or 45-50

      your ticket:
      7,1,14

      nearby tickets:
      7,3,47
      40,4,50
      55,2,20
      38,6,12
    INPUT
  end

  before { allow(Advent::Day16).to receive(:raw_input).and_return raw_input }

  describe "part 1" do
    subject { day.solve part: 1 }
    it { is_expected.to eq 71 }
  end

  describe "#rules" do
    let(:rules) { day.rules }

    describe "#name" do
      subject { rules.map(&:name) }
      it { is_expected.to eq %w(class row seat) }
    end

    describe "#ranges" do
      subject { rules.map(&:ranges) }
      it do
        is_expected.to eq([
          [[1, 3], [5, 7]],
          [[6, 11], [33, 44]],
          [[13, 40], [45, 50]],
        ])
      end
    end
  end

  describe "#tickets" do
    let(:tickets) { day.tickets }
    subject { tickets.map(&:numbers) }

    it do
      is_expected.to eq([
        [7, 1, 14],
        [7, 3, 47],
        [40, 4, 50],
        [55, 2, 20],
        [38, 6, 12],
      ])
    end
  end

  describe "#invalid values" do
    subject { day.invalid_values }
    it { is_expected.to match_array [4, 55, 12] }
  end

  describe Advent::Day16::RuleOrderDeducer do
    let(:raw_input) do
      <<~INPUT
        class: 0-1 or 4-19
        row: 0-5 or 8-19
        seat: 0-13 or 16-19

        your ticket:
        11,12,13

        nearby tickets:
        3,9,18
        15,1,5
        5,14,9
      INPUT
    end
    let(:rules) { day.rules }
    let(:tickets) { day.tickets }
    let(:deducer) { described_class.new rules, tickets }

    describe "possible_rules" do
      subject { deducer.possible_rules }
      it do
        is_expected.to eq([
          [rules[1]],
          [rules[0], rules[1]],
          [rules[0], rules[1], rules[2]]
        ])
      end
    end

    describe "#deduce_all" do
      subject { deducer.deduce_all.index_hash }
      it { is_expected.to eq({ rules[0] => 1, rules[1] => 0, rules[2] => 2 }) }
    end
  end
end

