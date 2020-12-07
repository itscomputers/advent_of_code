require 'advent/day07'

describe Advent::Day07 do
  let(:input) do
    [
      "light red bags contain 1 bright white bag, 2 muted yellow bags.",
      "dark orange bags contain 3 bright white bags, 4 muted yellow bags.",
      "bright white bags contain 1 shiny gold bag.",
      "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.",
      "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.",
      "dark olive bags contain 3 faded blue bags, 4 dotted black bags.",
      "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.",
      "faded blue bags contain no other bags.",
      "dotted black bags contain no other bags.",
    ]
  end
  let(:raw_input) { input.join("\n") }
  let(:day) { described_class.build }

  before { allow(described_class).to receive(:raw_input).and_return raw_input }

  describe '.sanitized_input' do
    subject { described_class.sanitized_input }
    it { is_expected.to eq input }
  end

  describe '#bag_for' do
    it "makes a new bag if necessary" do
      expect(day.instance_variable_get(:@bag_hash)).to be_empty
      expect(day.bag_for('overcast').color).to eq 'overcast'
      expect(day.instance_variable_get(:@bag_hash)).to eq({ 'overcast' => Advent::Day07::Bag.new('overcast') })
    end

    it "doesn't destroy bag info" do
      overcast_bag = day.bag_for('overcast')
      cloudy_bag = day.bag_for('cloudy')

      expect(day.bag_for('overcast')).to be overcast_bag
      expect(day.bag_for('cloudy')).to be cloudy_bag

      overcast_bag.add_parent(cloudy_bag)
      cloudy_bag.add_child(overcast_bag, 3)

      expect(day.bag_for('overcast').parents).to eq Set.new([cloudy_bag])
      expect(day.bag_for('cloudy').children).to eq [overcast_bag]
      expect(day.bag_for('cloudy').child_hash).to eq({ overcast_bag => 3 })
    end
  end

  describe '#process_rules' do
    let(:colors) { {
      "light red" => [[1, "bright white"], [2, "muted yellow"]],
      "bright white" => [[1, "shiny gold"]],
      "muted yellow" => [[2, "shiny gold"], [9, "faded blue"]],
      "dark orange" => [[3, "bright white"], [4, "muted yellow"]],
      "shiny gold" => [[1, "dark olive"], [2, "vibrant plum"]],
      "dark olive" =>  [[3, "faded blue"], [4, "dotted black"]],
      "vibrant plum" => [[5, "faded blue"], [6, "dotted black"]],
      "faded blue" => [],
      "dotted black" => [],
    } }

    it "populates all the bags with their connections" do
      day.process_rules!

      colors.each do |color, data|
        bag = day.bag_for(color)
        expect(bag.color).to eq color

        if data.empty?
          expect(bag.children).to be_empty
        end

        data.each do |q, c|
          expected_child = day.bag_for(c)
          expect(bag.children).to include expected_child
          expect(bag.child_hash[expected_child]).to eq q
          expect(expected_child.parents).to include bag
        end
      end
    end
  end

  describe "ancestors" do
    it "has all the ancestors" do
      day.process_rules!

      expect(day.bag_for("shiny gold").ancestors.map(&:color))
        .to match_array ["bright white", "muted yellow", "dark orange", "light red"]
    end
  end

  describe "interior_count" do
    it "has all the interior count" do
      day.process_rules!

      expect(day.bag_for("shiny gold").interior_count).to eq 32
    end
  end

  describe Advent::Day07::Rule do
    let(:multiple_children_rule) { input.first }
    let(:single_child_rule) { input[2] }
    let(:no_children_rule) { input.last }

    let(:rule) { described_class.new(string) }

    context "when multiple children are present" do
      let(:string) { multiple_children_rule }

      it { expect(rule.parent_color).to eq 'light red' }
      it { expect(rule.children_data).to match_array([
        { :quantity => 1, :color => "bright white" },
        { :quantity => 2, :color => "muted yellow" },
      ]) }
      it { expect(rule).to_not be_child_free }
    end

    context "when single child is present" do
      let(:string) { single_child_rule }

      it { expect(rule.parent_color).to eq 'bright white' }
      it { expect(rule.children_data).to match_array [{ :quantity => 1, :color => "shiny gold" }] }
      it { expect(rule).to_not be_child_free }
    end

    context "when no children are present" do
      let(:string) { no_children_rule }

      it { expect(rule.parent_color).to eq 'dotted black' }
      it { expect(rule.children_data).to be_empty }
      it { expect(rule).to be_child_free }
    end
  end
end

