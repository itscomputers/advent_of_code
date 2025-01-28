import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string

import args.{type Part, PartOne, PartTwo}
import regex
import util
import vector

type Pt {
  Pt(x: Int, y: Int, z: Int)
}

type Dir {
  X
  Y
  Z
}

type Brick {
  Brick(pt: Pt, dir: Dir, size: Int)
}

type Cube {
  Cube(
    deps: Dict(Brick, List(Brick)),
    reverse: Dict(Brick, List(Brick)),
    height: Int,
  )
}

type Resolver {
  Resolver(cube: Cube, falling: List(Brick))
}

type Disintegrator {
  Disintegrator(cube: Cube, frontier: List(Brick), vanished: Set(Brick))
}

pub fn main(input: String, part: Part) -> String {
  case part {
    PartOne -> input |> cube |> disintegrable_count |> int.to_string
    PartTwo -> input |> cube |> disintegration_count |> int.to_string
  }
}

fn disintegrable_count(cube: Cube) -> Int {
  cube.deps
  |> dict.fold(from: 0, with: fn(acc, _, deps) {
    case
      deps
      |> list.all(fn(dep) {
        cube.reverse
        |> dict.get(dep)
        |> result.map(fn(anchors) { list.length(anchors) > 1 })
        == Ok(True)
      })
    {
      True -> acc + 1
      _ -> acc
    }
  })
}

fn disintegration_count(cube: Cube) -> Int {
  cube.deps
  |> dict.keys
  |> list.fold(from: 0, with: fn(acc, brick) {
    cube
    |> disintegrator(brick)
    |> disintegrate
    |> fn(dis) { acc + set.size(dis.vanished) - 1 }
  })
}

fn disintegrator(cube: Cube, brick: Brick) -> Disintegrator {
  Disintegrator(cube:, frontier: [brick], vanished: set.new())
}

fn disintegrate(dis: Disintegrator) -> Disintegrator {
  case dis.frontier {
    [] -> dis
    bricks -> {
      let vanished = dis.vanished |> set.union(bricks |> set.from_list)
      let frontier =
        dis.cube.deps
        |> dict.take(bricks)
        |> dict.values
        |> list.flatten
        |> list.unique
        |> list.filter(fn(dep) {
          let assert Ok(anchors) = dis.cube.reverse |> dict.get(dep)
          anchors
          |> list.filter(fn(anchor) { !set.contains(vanished, anchor) })
          |> list.is_empty
        })
      Disintegrator(..dis, frontier:, vanished:) |> disintegrate
    }
  }
}

fn cube(input: String) -> Cube {
  let bricks =
    input
    |> util.lines
    |> list.map(build_brick)
    |> list.sort(by: fn(b1, b2) { int.compare(b1.pt.z, b2.pt.z) })
  Resolver(
    cube: Cube(dict.new(), reverse: dict.new(), height: 0),
    falling: bricks,
  )
  |> resolve
  |> set_reverse
}

fn resolve(resolver: Resolver) -> Cube {
  case resolver.falling {
    [] -> resolver.cube
    [brick, ..falling] ->
      Resolver(..resolver, falling:)
      |> process(brick)
      |> resolve
  }
}

fn process(resolver: Resolver, brick: Brick) -> Resolver {
  case brick.pt.z > resolver.cube.height + 1 {
    True -> brick |> drop(by: brick.pt.z - resolver.cube.height - 1)
    False -> brick
  }
  |> process_loop(resolver, _)
}

fn process_loop(resolver: Resolver, brick: Brick) -> Resolver {
  let candidate = brick |> drop(by: 1)
  case get_z(candidate) {
    #(0, _) -> Resolver(..resolver, cube: resolver.cube |> update_height(brick))
    #(min, _) ->
      case
        resolver.cube
        |> bricks_at(z: min)
        |> list.filter(collision(_, candidate))
      {
        [] -> process_loop(resolver, candidate)
        anchors -> {
          let cube =
            anchors
            |> list.fold(from: resolver.cube, with: fn(acc, anchor) {
              acc |> insert_dependency(anchor, brick)
            })
            |> update_height(brick)
          Resolver(..resolver, cube:)
        }
      }
  }
}

fn insert_dependency(cube: Cube, anchor: Brick, dependency: Brick) -> Cube {
  case cube.deps |> dict.get(anchor) {
    Ok(deps) ->
      Cube(..cube, deps: cube.deps |> dict.insert(anchor, [dependency, ..deps]))
    Error(_) ->
      Cube(..cube, deps: cube.deps |> dict.insert(anchor, [dependency]))
  }
}

fn update_height(cube: Cube, brick: Brick) -> Cube {
  let #(_, max) = get_z(brick)
  let height = int.max(cube.height, max)
  case cube.deps |> dict.get(brick) {
    Ok(_) -> Cube(..cube, height:)
    Error(_) -> Cube(..cube, deps: cube.deps |> dict.insert(brick, []), height:)
  }
}

fn set_reverse(cube: Cube) -> Cube {
  let reverse =
    cube.deps
    |> dict.fold(from: dict.new(), with: fn(acc, anchor, deps) {
      deps
      |> list.fold(from: acc, with: fn(acc, dep) {
        case acc |> dict.get(dep) {
          Ok(anchors) -> acc |> dict.insert(dep, [anchor, ..anchors])
          Error(_) -> acc |> dict.insert(dep, [anchor])
        }
      })
    })
  Cube(..cube, reverse:)
}

fn build_brick(line: String) -> Brick {
  let assert [str1, str2] = line |> string.split("~")
  let assert [x, y, z] = str1 |> regex.int_matches
  let pt1 = Pt(x:, y:, z:)
  let assert [x, y, z] = str2 |> regex.int_matches
  let pt2 = Pt(x:, y:, z:)
  let diff = vector.subtract(pt2 |> pt_to_vec, pt1 |> pt_to_vec)
  let #(size, dir) = case diff {
    [s, 0, 0] -> #(s, X)
    [0, s, 0] -> #(s, Y)
    [0, 0, s] -> #(s, Z)
    _ -> panic
  }
  case size > 0 {
    True -> Brick(pt: pt1, dir: dir, size:)
    False -> Brick(pt: pt2, dir: dir, size: -size)
  }
}

fn bricks_at(cube: Cube, z z: Int) -> List(Brick) {
  cube.deps
  |> dict.keys
  |> list.filter(brick_at(_, z))
}

fn brick_at(brick: Brick, z: Int) -> Bool {
  let #(min, max) = get_z(brick)
  min <= z && z <= max
}

fn drop(brick: Brick, by offset: Int) -> Brick {
  Brick(..brick, pt: Pt(..brick.pt, z: brick.pt.z - offset))
}

fn collision(b1: Brick, b2: Brick) -> Bool {
  !set.is_disjoint(pts(b1), pts(b2))
}

fn get_z(brick: Brick) -> #(Int, Int) {
  case brick.dir {
    X | Y -> #(brick.pt.z, brick.pt.z)
    Z -> #(brick.pt.z, brick.pt.z + brick.size)
  }
}

fn pts(brick: Brick) -> Set(Pt) {
  let vec = brick.pt |> pt_to_vec
  let dir = brick.dir |> dir_to_vec
  list.range(0, brick.size)
  |> list.map(fn(k) { vector.add(vec, vector.scale(dir, k)) |> pt_from_vec })
  |> set.from_list
}

fn pt_to_vec(pt: Pt) -> List(Int) {
  [pt.x, pt.y, pt.z]
}

fn pt_from_vec(vec: List(Int)) -> Pt {
  let assert [x, y, z] = vec
  Pt(x:, y:, z:)
}

fn dir_to_vec(dir: Dir) -> List(Int) {
  case dir {
    X -> [1, 0, 0]
    Y -> [0, 1, 0]
    Z -> [0, 0, 1]
  }
}
