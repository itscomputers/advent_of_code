require "year2021/day18"

describe Year2021::Day18 do
  let(:raw_input) do
    <<~RAW
      [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]
      [[[5,[2,8]],4],[5,[[9,9],0]]]
      [6,[[[6,2],[5,6]],[[7,6],[4,7]]]]
      [[[6,[0,7]],[0,9]],[4,[9,[9,0]]]]
      [[[7,[6,4]],[3,[1,3]]],[[[5,5],1],9]]
      [[6,[[7,3],[3,2]]],[[[3,8],[5,7]],4]]
      [[[[5,4],[7,7]],8],[[8,3],8]]
      [[9,3],[[9,9],[6,[4,9]]]]
      [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]
      [[[[5,2],5],[8,[3,7]]],[[5,[7,5]],[4,4]]]
    RAW
  end
  let(:day) { Year2021::Day18.new(raw_input) }
  let(:number) { Year2021::Day18::SnailFishNumber.for(input) }

  describe "part 1" do
    subject { day.solve(part: 1) }
    it { is_expected.to eq 4140 }
  end

  describe "part 2" do
    subject { day.solve(part: 2) }
    it { is_expected.to eq 3993 }

    describe "sum of [[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]] + [[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]" do
      let(:number) { Year2021::Day18::SnailFishNumber.for([[2,[[7,7],7]],[[5,8],[[9,3],[0,2]]]]) }
      let(:other) { Year2021::Day18::SnailFishNumber.for([[[0,[5,8]],[[1,7],[9,6]]],[[4,[1,2]],[[1,4],2]]]) }

      it "is [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]" do
        expect((number + other).to_a).to eq [[[[7,8],[6,6]],[[6,0],[7,7]]],[[[7,8],[8,8]],[[7,9],[0,6]]]]
      end

      it "has magnitude 3993" do
        expect((number + other).magnitude).to eq 3993
      end
    end
  end

  describe "explode" do
    describe "[[[[**[9,8]**,1],2],3],4]" do
      let(:input) { [[[[[9,8],1],2],3],4] }
      let(:entry) { number.left_regular.parent }

      before { expect(entry.to_a).to eq [9, 8] }

      it "becomes [[[[0,9],2],3],4]" do
        entry.explode!
        expect(number.to_a).to eq [[[[0,9],2],3],4]
      end
    end

    describe "[7,[6,[5,[4,**[3,2]**]]]]" do
      let(:input) { [7,[6,[5,[4,[3,2]]]]] }
      let(:entry) { number.right_regular.parent }

      before { expect(entry.to_a).to eq [3, 2] }

      it "becomes [7,[6,[5,[7,0]]]]" do
        entry.explode!
        expect(number.to_a).to eq [7,[6,[5,[7,0]]]]
      end
    end

    describe "[[6,[5,[4,**[3,2]**]]],1]" do
      let(:input) { [[6,[5,[4,[3,2]]]],1] }
      let(:entry) { number.left.right_regular.parent }

      before { expect(entry.to_a).to eq [3, 2] }

      it "becomes [[6,[5,[7,0]]],3]" do
        entry.explode!
        expect(number.to_a).to eq [[6,[5,[7,0]]],3]
      end
    end

    describe "[[3,[2,[1,**[7,3]**]]],[6,[5,[4,[3,2]]]]]" do
      let(:input) { [[3,[2,[1,[7,3]]]],[6,[5,[4,[3,2]]]]] }
      let(:entry) { number.left.right_regular.parent }

      before { expect(entry.to_a).to eq [7, 3] }

      it "becomes [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]" do
        entry.explode!
        expect(number.to_a).to eq [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]]
      end
    end

    describe "[[3,[2,[8,0]]],[9,[5,[4,**[3,2]**]]]]" do
      let(:input) { [[3,[2,[8,0]]],[9,[5,[4,[3,2]]]]] }
      let(:entry) { number.right_regular.parent }

      before { expect(entry.to_a).to eq [3, 2] }

      it "becomes [[3,[2,[8,0]]],[9,[5,[7,0]]]]" do
        entry.explode!
        expect(number.to_a).to eq [[3,[2,[8,0]]],[9,[5,[7,0]]]]
      end
    end
  end

  describe "split!" do
    describe "[**10**, 1]" do
      let(:input) { [10, 1] }
      it "becomes [[5,5], 1]" do
        number.left.split!
        expect(number.to_a).to eq [[5,5], 1]
      end
    end

    describe "[**11**, 1]" do
      let(:input) { [11, 1] }
      it "becomes [[5,6], 1]" do
        number.left.split!
        expect(number.to_a).to eq [[5,6], 1]
      end
    end
  end

  describe "replace_with" do
    let(:input) { [[4,[3,2]],[1,0]] }

    describe "replacing 4 with [4,10]" do
      let(:entry) { number.left.left }

      before { expect(entry.value).to eq 4 }

      it "becomes [[[4,10],[3,2]],[1,0]]" do
        entry.replace_with([4, 10])
        expect(number.to_a).to eq [[[4,10],[3,2]],[1,0]]
        number.left.left.tap do |new_entry|
          expect(new_entry.to_a).to eq [4,10]
          expect(new_entry.left.value).to eq 4
          expect(new_entry.right.value).to eq 10
          expect(new_entry.left.parent).to eq new_entry
          expect(new_entry.right.parent).to eq new_entry
          expect(new_entry.parent).to eq number.left
        end
      end
    end
  end

  describe "pairs" do
    describe "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]" do
      let(:input) { [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]] }

      it "is [[4,3],[8,4],[1,1]]" do
        expect(number.pairs.map(&:to_a)).to eq [[4,3],[8,4],[1,1]]
      end
    end
  end

  describe "explode_candidate" do
    describe "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]" do
      let(:input) { [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]] }
      it "is [4,3]" do
        expect(number.explode_candidate.to_a).to eq [4,3]
      end
    end
  end

  describe "regulars" do
    describe "[[[[4,3],4],4],[7,[[8,4],9]]]" do
      let(:input) { [[[[4,3],4],4],[7,[[8,4],9]]] }
      it "is the flattened values" do
        expect(number.regulars.map(&:value)).to eq input.flatten
      end
    end
  end

  describe "reduce single" do
    describe "[[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]]" do
      let(:input) { [[[[[4,3],4],4],[7,[[8,4],9]]],[1,1]] }

      before { expect(number.explode_candidate.to_a).to eq [4,3] }

      it "becomes [[[[0,7],4],[7,[[8,4],9]]],[1,1]]" do
        number.reduce_single
        expect(number.to_a).to eq [[[[0,7],4],[7,[[8,4],9]]],[1,1]]
      end
    end

    describe "[[[[0,7],4],[7,[[8,4],9]]],[1,1]]" do
      let(:input) { [[[[0,7],4],[7,[[8,4],9]]],[1,1]] }

      before { expect(number.explode_candidate.to_a).to eq [8,4] }

      it "becomes [[[[0,7],4],[15,[0,13]]],[1,1]]" do
        number.reduce_single
        expect(number.to_a).to eq [[[[0,7],4],[15,[0,13]]],[1,1]]
      end
    end

    describe "[[[[0,7],4],[15,[0,13]]],[1,1]]" do
      let(:input) { [[[[0,7],4],[15,[0,13]]],[1,1]] }

      before do
        expect(number.explode_candidate).to be_nil
        expect(number.split_candidate.value).to eq 15
      end

      it "becomes [[[[0,7],4],[[7,8],[0,13]]],[1,1]]" do
        number.reduce_single
        expect(number.to_a).to eq [[[[0,7],4],[[7,8],[0,13]]],[1,1]]
      end
    end

    describe "[[[[0,7],4],[[7,8],[0,13]]],[1,1]]" do
      let(:input) { [[[[0,7],4],[[7,8],[0,13]]],[1,1]] }

      before do
        expect(number.explode_candidate).to be_nil
        expect(number.split_candidate.value).to eq 13
      end

      it "becomes [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]" do
        number.reduce_single
        expect(number.to_a).to eq [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]
      end
    end

    describe "[[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]]" do
      let(:input) { [[[[0,7],4],[[7,8],[0,[6,7]]]],[1,1]] }

      before { expect(number.explode_candidate.to_a).to eq [6,7] }

      it "becomes [[[[0,7],4],[[7,8],[6,0]]],[8,1]]" do
        number.reduce_single
        expect(number.to_a).to eq [[[[0,7],4],[[7,8],[6,0]]],[8,1]]
      end
    end
  end

  describe "addition" do
    let(:input) { [[[[4,3],4],4],[7,[[8,4],9]]] }
    let(:other) { Year2021::Day18::SnailFishNumber.for([1,1]) }

    it "adds to [[[[0,7],4],[[7,8],[6,0]]],[8,1]]" do
      expect((number + other).to_a).to eq [[[[0,7],4],[[7,8],[6,0]]],[8,1]]
    end
  end
end
