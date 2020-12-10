require 'advent/day09'

describe Advent::Day09 do
  let(:input) { [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 277, 309, 576 ] }
  let(:block_length) { 5 }

  describe 'part 1' do
    subject { described_class.new(input, block_length: block_length).solve part: 1 }
    it { is_expected.to eq 127 }
  end

  describe 'part 2' do
    subject { described_class.new(input, block_length: block_length).solve part: 2 }
    it { is_expected.to eq 62 }
  end

  describe Advent::Day09::Block do
    let(:block) { described_class.new numbers }

    describe 'first 25 numbers' do
      let(:numbers) { [20, *(1..19).to_a, *(21..25).to_a] }

      describe '#sums' do
        subject { block.sums }
        it { is_expected.to eq (3..49).to_set }
      end

      describe '#valid?' do
        subject { block.valid? new_number }

        context "when new number is 26" do
          let(:new_number) { 26 }
          it { is_expected.to be true }
        end

        context "when new number is 49" do
          let(:new_number) { 49 }
          it { is_expected.to be true }
        end

        context "when new number is 100" do
          let(:new_number) { 100 }
          it { is_expected.to be false }
        end

        context "when new number is 50" do
          let(:new_number) { 50 }
          it { is_expected.to be false }
        end
      end

      describe '#shift!' do
        context "when new number is 45" do
          let(:new_number) { 45 }
          let(:expected_numbers) { [*numbers.drop(1), 45] }
          let(:expected_numbers_hash) do
            expected_numbers.combination(2).each_with_object(Hash.new { |h, k| h[k] = [] }) do |p, m|
              m[p.first] << p.sum
            end
          end

          it "has original minus first and 45 as numbers" do
            expect { block.shift! new_number }
              .to change { block.numbers }
              .from(numbers)
              .to expected_numbers
          end

          it "recomputes the numbers hash" do
            expect { block.shift! new_number }
              .to change { block.sums }
              .from((3..49).to_set)
              .to expected_numbers_hash.values.flatten.to_set
          end
        end
      end
    end
  end



end

