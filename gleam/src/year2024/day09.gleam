import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/string

import args.{type Part, PartOne, PartTwo}
import range.{type Range, Range}

type DiskMap {
  DiskMap(files: List(File), compressed: List(File), spaces: List(Range))
}

type File {
  File(id: Int, range: Range)
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> disk_map |> compress |> checksum |> int.to_string
    PartTwo -> input |> disk_map |> compress_v2 |> checksum |> int.to_string
  }
}

fn preprocess(input: String) -> List(Int) {
  input
  |> string.split("")
  |> list.map(int.parse)
  |> list.fold(from: [0], with: fn(acc, res) {
    case res, acc |> list.first {
      Ok(value), Ok(first) -> [value + first, ..acc]
      _, _ -> acc
    }
  })
  |> list.reverse
}

fn disk_map(input: String) -> DiskMap {
  input
  |> preprocess
  |> list.window_by_2
  |> list.index_fold(
    from: DiskMap(files: [], compressed: [], spaces: []),
    with: fn(map, tuple, index) {
      let range = Range(tuple.0, tuple.1)
      case index % 2 == 0 {
        True ->
          DiskMap(
            ..map,
            files: [File(id: index / 2, range: range), ..map.files],
          )
        _ -> DiskMap(..map, spaces: [range, ..map.spaces])
      }
    },
  )
  |> fn(map) { DiskMap(..map, spaces: map.spaces |> list.reverse) }
  // |> display
}

fn checksum(map: DiskMap) -> Int {
  map.compressed
  |> list.append(map.files)
  |> list.fold(from: 0, with: fn(acc, file) {
    acc + file.id * { file.range |> range.values |> int.sum }
  })
}

fn compress(map: DiskMap) -> DiskMap {
  case map.files, map.spaces {
    [], _ -> map
    _, [] -> map
    [file, ..files], [space, ..spaces] -> {
      case file |> compare(space) {
        Eq | Lt -> map
        Gt -> {
          let new_file = file |> shift(to: space)
          case new_file |> compare(space) {
            Lt -> {
              let spaces = [Range(new_file.range.upper, space.upper), ..spaces]
              let compressed = [new_file, ..map.compressed]
              DiskMap(files:, spaces:, compressed:)
            }
            Eq -> {
              let compressed = [new_file, ..map.compressed]
              DiskMap(files:, spaces:, compressed:)
            }
            Gt -> {
              let range = new_file.range |> range.intersection(space)
              let new_file = File(..new_file, range:)
              let compressed = [new_file, ..map.compressed]
              let range =
                Range(
                  file.range.lower,
                  file.range.upper - { space |> range.size },
                )
              let leftover = File(..file, range:)
              let files = [leftover, ..files]
              DiskMap(files:, spaces:, compressed:)
            }
          }
          |> compress
        }
      }
    }
  }
}

fn compress_v2(map: DiskMap) -> DiskMap {
  case map.files {
    [] -> map
    [file, ..files] -> {
      case
        map.spaces
        |> list.find(fn(space) {
          file |> compare(space) == Gt
          && { file |> shift(to: space) }.range |> range.subrange(of: space)
        })
      {
        Error(_) -> {
          let compressed = [file, ..map.compressed]
          DiskMap(..map, files:, compressed:)
        }
        Ok(space) -> {
          let new_file = file |> shift(to: space)
          let spaces =
            [
              Range(new_file.range.upper, space.upper),
              ..map.spaces
              |> list.filter(fn(sp) { sp != space })
            ]
            |> list.sort(by: range.compare)
          let compressed = [new_file, ..map.compressed]
          DiskMap(files:, compressed:, spaces:)
        }
      }
      |> compress_v2
    }
  }
}

fn shift(file: File, to space: Range) -> File {
  File(
    ..file,
    range: file.range |> range.shift(by: space.lower - file.range.lower),
  )
}

fn compare(file: File, space: Range) -> Order {
  file.range |> range.compare(space)
}
// fn display(map: DiskMap) -> DiskMap {
//   let files =
//     [map.files, map.compressed]
//     |> list.flatten
//     |> list.sort(by: fn(a, b) { a.range |> range.compare(b.range) })
//   let assert Ok(file) = files |> list.last
//   let extra = File(id: -1, range: Range(file.range.upper, file.range.upper))
//   list.append(files, [extra])
//   |> list.window_by_2
//   |> list.fold(from: [], with: fn(acc, tuple) {
//     let #(file, other): #(File, File) = tuple
//     list.flatten([
//       list.repeat(".", other.range.lower - file.range.upper),
//       list.repeat(file.id |> int.to_string, file.range |> range.size),
//       acc,
//     ])
//   })
//   |> list.reverse
//   |> string.join("")
//   |> util.debug("DiskMap")
//   map
// }
