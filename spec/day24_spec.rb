require 'advent/day24'

describe Advent::Day24 do
  let(:day) { Advent::Day24.build }
  let(:raw_input) do
    <<~INPUT
      sesenwnenenewseeswwswswwnenewsewsw
      neeenesenwnwwswnenewnwwsewnenwseswesw
      seswneswswsenwwnwse
      nwnwneseeswswnenewneswwnewseswneseene
      swweswneswnenwsewnwneneseenw
      eesenwseswswnenwswnwnwsewwnwsene
      sewnenenenesenwsewnenwwwse
      wenwwweseeeweswwwnwwe
      wsweesenenewnwwnwsenewsenwwsesesenwne
      neeswseenwwswnwswswnw
      nenwswwsewswnenenewsenwsenwnesesenew
      enewnwewneswsewnwswenweswnenwsenwsw
      sweneswneswneneenwnewenewwneswswnese
      swwesenesewenwneswnwwneseswwne
      enesenwswwswneneswsenwnewswseenwsese
      wnwnesenesenenwwnenwsewesewsesesew
      nenewswnwewswnenesenwnesewesw
      eneswnwswnwsenenwnwnwwseeswneewsenese
      neswnwewnwnwseenwseesewsenwsweewe
      wseweeenwnesenwwwswnew
    INPUT
  end

  before { allow(Advent::Day24).to receive(:raw_input).and_return raw_input }

  describe 'part 1' do
    subject { day.solve part: 1 }
    it { is_expected.to eq 10 }
  end

# slow spec
# describe 'part 2' do
#   subject { day.solve part: 2 }
#   it { is_expected.to eq 2208 }
# end

  describe Advent::Day24::TileFloor::Tile do
    let(:tile) { described_class.new(string) }
    subject { tile.directions }

    context "when string is sesenwnenenewseeswwswswwnenewsewsw" do
      let(:string) { "sesenwnenenewseeswwswswwnenewsewsw" }
      it { is_expected.to eq %w(se se nw ne ne ne w se e sw w sw sw w ne ne w se w sw) }
    end
  end
end

