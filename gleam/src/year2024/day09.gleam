import args.{type Part, PartOne, PartTwo}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/order.{type Order, Eq, Gt, Lt}
import gleam/string

import range.{type Range, Range}
import util

type DiskMap {
  DiskMap(files: Dict(Int, File), spaces: List(Int))
}

type File {
  File(id: Int)
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> disk_map |> compress |> checksum |> int.to_string
    PartTwo ->
      input
      |> disk_map_v2
      |> compress_v2
      |> checksum_v2
      |> int.to_string
  }
}

fn preprocess(input: String) -> List(Int) {
  input
  |> string.split("")
  |> list.map(int.parse)
  |> list.index_fold(from: [], with: fn(acc, res, index) {
    case res {
      Ok(value) if index % 2 == 0 ->
        list.append(acc, list.repeat(index / 2, times: value))
      Ok(value) -> list.append(acc, list.repeat(-1, times: value))
      Error(_) -> acc
    }
  })
}

fn disk_map(input: String) -> DiskMap {
  input
  |> preprocess
  |> list.index_fold(from: DiskMap(dict.new(), []), with: fn(map, id, index) {
    case id == -1 {
      False -> DiskMap(..map, files: map.files |> dict.insert(index, File(id)))
      True -> DiskMap(..map, spaces: [index, ..map.spaces])
    }
  })
  |> fn(map) { DiskMap(..map, spaces: map.spaces |> list.reverse) }
}

fn compress(map: DiskMap) -> DiskMap {
  case map.spaces {
    [] -> map
    [space, ..spaces] -> {
      let max_index = map |> max_file_index
      case max_index > space {
        True -> {
          let assert Ok(file) = map.files |> dict.get(max_index)
          map.files
          |> dict.insert(space, file)
          |> dict.delete(max_index)
          |> DiskMap(files: _, spaces:)
          |> compress
        }
        False -> map
      }
    }
  }
}

fn checksum(map: DiskMap) -> Int {
  map.files
  |> dict.fold(from: 0, with: fn(acc, index, file) { acc + index * file.id })
}

fn max_file_index(map: DiskMap) -> Int {
  map.files |> dict.keys |> list.fold(from: 0, with: int.max)
}

fn display(map: DiskMap) -> DiskMap {
  list.range(0, map |> max_file_index)
  |> list.map(fn(index) {
    case map.files |> dict.get(index) {
      Ok(file) -> file.id |> int.to_string
      Error(_) -> "."
    }
  })
  |> string.join("")
  |> util.debug("DiskMap")
  map
}

type DiskMapV2 {
  DiskMapV2(files: List(FileV2), spaces: List(Range))
}

type FileV2 {
  FileV2(id: Int, range: Range, processed: Bool)
}

fn preprocess_v2(input: String) -> List(Int) {
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

fn disk_map_v2(input: String) -> DiskMapV2 {
  input
  |> preprocess_v2
  |> list.window_by_2
  |> list.index_fold(
    from: DiskMapV2(files: [], spaces: []),
    with: fn(map, tuple, index) {
      let range = Range(tuple.0, tuple.1)
      case index % 2 == 0 {
        True ->
          DiskMapV2(
            ..map,
            files: [
              FileV2(id: index / 2, range: range, processed: False),
              ..map.files
            ],
          )
        _ -> DiskMapV2(..map, spaces: [range, ..map.spaces])
      }
    },
  )
  |> reduce
}

fn reduce(map: DiskMapV2) -> DiskMapV2 {
  DiskMapV2(
    files: map.files |> list.sort(by: compare),
    spaces: map.spaces |> list.sort(by: range.compare),
  )
}

fn compress_v2(map: DiskMapV2) -> DiskMapV2 {
  case map.files |> list.reverse {
    [file, ..files] -> {
      case file.processed {
        True -> map
        False ->
          case
            map.spaces
            |> list.find(fn(space) {
              space |> range.size >= file.range |> range.size
              && space.lower < file.range.lower
            })
          {
            Ok(space) -> {
              let new_range =
                file.range |> range.offset(by: space.lower - file.range.lower)
              let spaces = map.spaces |> list.filter(fn(sp) { sp != space })
              case new_range == space {
                True ->
                  DiskMapV2(
                    files: [
                      FileV2(..file, range: new_range, processed: True),
                      ..list.reverse(files)
                    ],
                    spaces: [file.range, ..spaces],
                  )
                False -> {
                  let spaces =
                    list.append(
                      [Range(new_range.upper, space.upper), file.range],
                      spaces,
                    )
                  DiskMapV2(
                    files: [
                      FileV2(..file, range: new_range, processed: True),
                      ..list.reverse(files)
                    ],
                    spaces:,
                  )
                }
              }
            }
            Error(_) ->
              DiskMapV2(
                ..map,
                files: [FileV2(..file, processed: True), ..list.reverse(files)],
              )
          }
          |> compress_v2
      }
    }
    _ -> map
  }
}

fn checksum_v2(map: DiskMapV2) -> Int {
  map.files
  |> list.fold(from: 0, with: fn(acc, file) {
    acc + file.id * { file.range |> range.values |> int.sum }
  })
}

fn compare(file: FileV2, other: FileV2) -> Order {
  file.range |> range.compare(other.range)
}

fn display_v2(map: DiskMapV2) -> DiskMapV2 {
  let assert Ok(file) = map.files |> list.last
  let extra =
    FileV2(
      id: -1,
      range: Range(file.range.upper, file.range.upper),
      processed: False,
    )
  map.files
  |> list.append([extra])
  |> list.sort(by: compare)
  |> list.window_by_2
  |> list.fold(from: [], with: fn(acc, tuple) {
    let #(file, other): #(FileV2, FileV2) = tuple
    list.flatten([
      list.repeat(".", other.range.lower - file.range.upper),
      list.repeat(file.id |> int.to_string, file.range |> range.size),
      acc,
    ])
  })
  |> list.reverse
  |> string.join("")
  |> util.debug("DiskMap")
  map
}
